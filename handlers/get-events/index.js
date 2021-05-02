'use strict';

const { MongoClient } = require('mongodb');
const { MONGODB_URI, MONGODB_USER, MONGODB_PASSWORD } = process.env;

let conn;

const createConnectionAuthOptions = () =>
  MONGODB_USER && MONGODB_PASSWORD
    ? {
        user: MONGODB_USER,
        password: MONGODB_PASSWORD,
      }
    : {};

// TODO: lambda layer
const getDBConnection = async () => {
  if (!conn) {
    conn = await MongoClient.connect(MONGODB_URI, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
      ...createConnectionAuthOptions(),
    });
  }

  return conn;
};

const createRes = (statusCode, body) => ({
  statusCode,
  headers: {
    'Content-Type': 'application/json',
  },
  isBase64Encoded: false,
  body: JSON.stringify(body),
});

// TODO: validate in API Gateway instead
const validateParams = (queryParams) => {
  for (let param of ['deviceID', 'date', 'eventType']) {
    if (!queryParams[param]) {
      throw new Error(`${param} is missing from query params`);
    }
  }
};

exports.handler = async ({ queryStringParameters }) => {
  const connection = await getDBConnection();

  try {
    validateParams(queryStringParameters);
  } catch ({ message }) {
    return createRes(400, {
      message,
    });
  }

  const { deviceID, date, eventType } = queryStringParameters;

  try {
    const events = await connection
      .db('events')
      .collection('events')
      .aggregate([
        {
          $limit: 1,
        },
        {
          $match: {
            deviceID,
            date: new Date(date),
            eventType,
          },
        },
        {
          $unwind: '$events',
        },
        {
          $project: {
            _id: 0,
            date: '$events.date',
            value: '$events.value',
          },
        },
      ])
      .toArray();

    return createRes(200, events);
  } catch ({ message }) {
    return createRes(500, {
      message,
    });
  }
};
