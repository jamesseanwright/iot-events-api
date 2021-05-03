'use strict';

const { getDBConnection, createRes } = require('../common');

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
          $match: {
            deviceID,
            date: new Date(date),
            eventType,
          },
        },
        {
          $limit: 1, // TODO: verify with execution plan
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
