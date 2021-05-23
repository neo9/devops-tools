import { createServer, IncomingMessage, ServerResponse } from 'http';

const requestListener = function (req: IncomingMessage, res: ServerResponse) {
  res.writeHead(200, {"Content-Type": "application/json"});
  // res.write(JSON.stringify(process.env));
  res.write("TS");
  res.end();
}

const server = createServer(requestListener);
server.listen(8080)