'use strict';

const { MongoClient } = require('mongodb');
const { MONGODB_URI } = process.env;

let conn;

// TODO: lambda layer
const getDBConnection = async () => {
  if (!conn) {
    conn = await MongoClient.connect(MONGODB_URI, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });
  }

  return conn;
};

// TODO: lambda layer
const createRes = (statusCode, message) => ({
  statusCode,
  headers: {
    'Content-Type': 'application/json',
  },
  isBase64Encoded: false,
  body: JSON.stringify({ message }),
});

exports.handler = async ({ body }) => {
  const connection = await getDBConnection();
  const { date, deviceID, eventType } = JSON.parse(body);

  try {
    const {
      result: { ok },
    } = await connection
      .db('events')
      .collection('events')
      .insertOne({
        date: new Date(date),
        deviceID,
        eventType,
      });

    return ok
      ? createRes(201, 'Created event')
      : createRes(500, 'Unable to create event');
  } catch ({ message }) {
    return createRes(500, message);
  }
};
