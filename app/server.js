const http = require('node:http');
const { scanSync, scanAsync } = require('./scanner');

const MODE = process.env.MODE || 'sync';

// Lag monitor: a timer that should fire every 100 ms tells us when the loop was stuck.
let last = Date.now();
setInterval(() => {
  const now = Date.now();
  if (now - last > 500) console.log(`event loop was blocked for ${now - last} ms`);
  last = now;
}, 100);

function send(res, body) {
  res.setHeader('content-type', 'application/json');
  res.end(JSON.stringify(body) + '\n');
}

http
  .createServer(async (req, res) => {
    if (req.url === '/projects') {
      const projects = MODE === 'async' ? await scanAsync() : scanSync();
      return send(res, { projects });
    }
    send(res, { ok: true });
  })
  .listen(3000, () => console.log(`listening on 3000, mode ${MODE}`));
