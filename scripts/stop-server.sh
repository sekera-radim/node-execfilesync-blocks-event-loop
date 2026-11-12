#!/bin/bash
[ -f /tmp/server.pid ] && kill "$(cat /tmp/server.pid)" 2>/dev/null
for i in $(seq 1 50); do curl -fs -m 1 http://localhost:3000/ >/dev/null 2>&1 || break; sleep 0.1; done
rm -f /tmp/server.pid
echo "server stopped"
