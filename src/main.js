const http = require('http');

const requestListener = function (req, res) {
  res.writeHead(200, {"Content-Type": "application/json"});
  // res.write(JSON.stringify(process.env));
  res.write("JS");
  res.end();
}

const server = http.createServer(requestListener);
server.listen(8080);
