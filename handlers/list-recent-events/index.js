'use strict';

const { MongoClient } = require('mongodb');
const { MONGODB_URI } = process.env;

let conn;

const getDBConnection = async () => {
  if (!conn) {
    conn = await MongoClient.connect(MONGODB_URI, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
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

exports.handler = async () => {
  const connection = await getDBConnection();

  try {
    const events = await connection
      .db('events')
      .collection('events')
      .find(
        {},
        {
          limit: 10,
          sort: [['date', -1]],
        },
      )
      .toArray();

    return createRes(200, events);
  } catch ({ message }) {
    return createRes(500, {
      message,
    });
  }
};
