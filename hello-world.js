'use strict';

exports.handler = async () => ({
  statusCode: 200,
  headers: {
    'Content-Type': 'text/plain',
  },
  isBase64Encoded: false,
  body: 'Hello world!',
});
