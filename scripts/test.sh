#!/bin/bash
set -uo pipefail
fail() { echo "FAIL: $1"; bash ~/scripts/stop-server.sh >/dev/null 2>&1; exit 1; }
cd ~

bash scripts/start-server.sh sync >/dev/null
curl -s localhost:3000/projects >/tmp/t1.json &
sleep 0.3
curl -fs -m 2 localhost:3000/ >/dev/null 2>&1 && fail "the server should not answer while the sync scan runs"
echo "ok 1 - during the sync scan the server answers nothing, not even a trivial request"
wait
grep -q "scanned repo-d" /tmp/t1.json || fail "the scan itself should finish"
sleep 0.3
grep -q "event loop was blocked for" /tmp/server.log || fail "the lag monitor should report the block"
echo "ok 2 - the lag monitor reports the event loop was blocked for seconds"
bash scripts/stop-server.sh >/dev/null

node app/timeout-probe.js >/tmp/t3.log
grep -q "ETIMEDOUT" /tmp/t3.log || fail "the timeout should be reported"
ms=$(grep -o 'after [0-9]*' /tmp/t3.log | grep -o '[0-9]*')
[ "$ms" -ge 2500 ] || fail "the call should still block until the child exits (got $ms ms)"
echo "ok 3 - timeout 500 ms on execFileSync still blocked about 3 s: the child ignored the signal"

bash scripts/start-server.sh async >/dev/null
curl -s localhost:3000/projects >/tmp/t4.json &
sleep 0.3
curl -fs -m 2 localhost:3000/ | grep -q '"ok":true' || fail "the async server should answer during the scan"
echo "ok 4 - with async execFile the server answers while the scan runs"
wait
grep -q "scanned repo-d" /tmp/t4.json || fail "the async scan should finish"
grep -q "event loop was blocked" /tmp/server.log && fail "the event loop should never be blocked"
echo "ok 5 - the scan finishes and the lag monitor stays silent"
bash scripts/stop-server.sh >/dev/null

echo "ALL PASSED"
