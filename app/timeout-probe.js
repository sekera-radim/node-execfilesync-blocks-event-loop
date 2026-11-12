// Does the `timeout` option of execFileSync bound how long the call blocks?
const { execFileSync } = require('node:child_process');
const { TOOL } = require('./scanner');

const started = Date.now();
try {
  execFileSync(TOOL, ['repo-a'], { timeout: 500, env: { ...process.env, SLOW_SECONDS: '3' } });
} catch (err) {
  console.log(`execFileSync threw: ${err.code}`);
}
console.log(`asked for timeout 500 ms, call returned after ${Date.now() - started} ms`);
