'use strict';

const { getDBConnection, createRes } = require('../common');

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
      ? createRes(201, { message: 'Created event' })
      : createRes(500, { message: 'Unable to create event' });
  } catch ({ message }) {
    return createRes(500, { message });
  }
};
