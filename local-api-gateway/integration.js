'use strict';

function invoke(r) {
  var payload = {
    body: r.requestText,
    queryStringParameters: r.args,
  };

  r.subrequest('/integration', {
    method: 'POST',
    body: JSON.stringify(payload),
  }).then(function (res) {
    try {
      var integrationRes = JSON.parse(res.responseText);

      for (var headerName in integrationRes.headers) {
        r.headersOut[headerName] = integrationRes.headers[headerName];
      }

      r.return(integrationRes.statusCode, integrationRes.body);
    } catch (e) {
      r.return(500, e.message);
    }
  });
}

// `export function function (){}` isn't supported
export default { invoke };
