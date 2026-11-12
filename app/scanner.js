const { execFileSync, execFile } = require('node:child_process');
const { promisify } = require('node:util');
const path = require('node:path');

const execFileAsync = promisify(execFile);
const TOOL = path.join(__dirname, 'slow-tool.sh');
const REPOS = ['repo-a', 'repo-b', 'repo-c', 'repo-d'];

// Broken: every call blocks the whole process until the child exits.
function scanSync() {
  return REPOS.map((repo) => execFileSync(TOOL, [repo], { encoding: 'utf8' }).trim());
}

// Fixed: the children run in parallel and the event loop stays free.
async function scanAsync() {
  const results = await Promise.all(REPOS.map((repo) => execFileAsync(TOOL, [repo])));
  return results.map((r) => r.stdout.trim());
}

module.exports = { scanSync, scanAsync, TOOL };
