'use strict';

const path = require('path');

const [, , handlerName, body] = process.argv;

(async () => {
  const { handler } = require(path.resolve(__dirname, '..', 'handlers', handlerName))
  const result = await handler({ body });

  console.log(result);
})();
