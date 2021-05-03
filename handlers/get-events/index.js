'use strict';

const { getDBConnection, createRes } = require('../common');

exports.handler = async ({ queryStringParameters }) => {
  const connection = await getDBConnection();

  // TODO: validate in API Gateway
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
