#!/bin/bash
# Start the server in the background: start-server.sh sync|async
cd ~/app
MODE="${1:-sync}" nohup node server.js >/tmp/server.log 2>&1 &
echo $! > /tmp/server.pid
for i in $(seq 1 50); do curl -fs -m 1 http://localhost:3000/ >/dev/null 2>&1 && break; sleep 0.1; done
cat /tmp/server.log
