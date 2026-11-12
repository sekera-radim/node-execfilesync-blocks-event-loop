# Node server unresponsive: execFileSync and the event loop

A small Node.js server scans four "repositories" by running an external command for each one.
With `execFileSync` the whole process is blocked until every child exits: while the scan runs,
the server cannot answer even a trivial request. The `timeout` option does not bound the block
when the child cannot or will not react to the signal. With the promise form of `execFile`
the children run in parallel and the event loop stays free.

`app/slow-tool.sh` is a stand-in for an external command that became slow. It sleeps and ignores SIGTERM.

## Run it

```bash
docker build -t execfilesync-demo .
docker run --rm execfilesync-demo
```

The test prints five `ok` lines and `ALL PASSED`.

- `app/scanner.js`: `scanSync` (broken) and `scanAsync` (fixed)
- `app/server.js`: the server with an event-loop lag monitor, `MODE=sync|async`
- `app/timeout-probe.js`: measures how long `execFileSync` blocks with `timeout: 500`
- `scripts/test.sh`: every step shown in the video
