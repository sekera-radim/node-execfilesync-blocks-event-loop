#!/bin/bash
# Stands in for an external command that got slow (for us: git under disk pressure).
# It also ignores SIGTERM, like a process that is stuck and cannot react to signals.
trap '' TERM
sleep "${SLOW_SECONDS:-1.5}"
echo "scanned $1"
