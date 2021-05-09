'use strict';

export default function invoke(r) {
  var payload = {
    body: r.requestText,
    queryParameters: r.args,
  };

  r.subrequest(`http://${r.variables.handler_host}/2015-03-31/functions/function/invocations`, {
    method: 'POST',
    body: JSON.stringify(payload),
  }).then(function (res) {
    r.return(res.status, res.responseBody);
  });
}