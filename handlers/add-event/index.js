'use strict';

const { Binary, MongoClient } = require('mongodb');
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
const createRes = (statusCode, body) => ({
  statusCode,
  headers: {
    'Content-Type': 'application/json',
  },
  isBase64Encoded: false,
  body: JSON.stringify(body),
});

// TODO: lambda layer
const asUUID = value => new Binary(
  Buffer.from(value),
  Binary.SUBTYPE_UUID,
)

exports.handler = async ({ body }) => {
  const connection = await getDBConnection();
  const { date, deviceID, eventType } = JSON.parse(body);

  try {
    const events = await connection
      .db('events')
      .collection('events')
      .insertOne({
        date: new Date(date),
        deviceID: asUUID(deviceID),
        eventType,
      });

    return createRes(200, events);
  } catch ({ message }) {
    return createRes(500, {
      message,
    });
  }
};
