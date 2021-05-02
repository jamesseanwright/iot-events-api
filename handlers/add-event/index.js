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

// TODO: lambda layer
const createRes = (statusCode, message) => ({
  statusCode,
  headers: {
    'Content-Type': 'application/json',
  },
  isBase64Encoded: false,
  body: JSON.stringify({ message }),
});

const floorDate = (date) => {
  const floored = new Date(date);

  floored.setUTCHours(0);
  floored.setUTCMinutes(0);
  floored.setUTCSeconds(0);
  floored.setUTCMilliseconds(0);

  return floored;
};

exports.handler = async ({ body }) => {
  const connection = await getDBConnection();
  const { date: isoDateString, deviceID, eventType, value } = JSON.parse(body);
  const date = new Date(isoDateString);

  try {
    const {
      result: { ok },
    } = await connection
      .db('events')
      .collection('events')
      .updateOne(
        {
          deviceID,
          date: floorDate(date),
          eventType,
        },
        {
          $push: {
            events: {
              $each: [
                {
                  date,
                  value,
                },
              ],
              $position: 0,
            },
          },
        },
        {
          upsert: true,
        },
      );

    return ok
      ? createRes(201, 'Created event')
      : createRes(500, 'Unable to create event');
  } catch ({ message }) {
    return createRes(500, message);
  }
};
