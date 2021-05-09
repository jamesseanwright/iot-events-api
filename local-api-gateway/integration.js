'use strict';

function buildBody(r) {
  return JSON.stringify({
    body: r.requestText,
    queryStringParameters: r.args,
  });
}

// `export function function (){}` isn't supported
export default { buildBody };
