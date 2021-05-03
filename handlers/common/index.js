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

exports.getDBConnection = async () => {
  if (!conn) {
    conn = await MongoClient.connect(MONGODB_URI, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
      ...createConnectionAuthOptions(),
    });
  }

  return conn;
};

exports.createRes = (statusCode, body) => ({
  statusCode,
  headers: {
    'Content-Type': 'application/json',
  },
  isBase64Encoded: false,
  body: JSON.stringify(body),
});
