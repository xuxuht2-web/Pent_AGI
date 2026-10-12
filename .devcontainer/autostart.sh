#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "$0")/.."
mkdir -p .pentagi-state
nohup bash .devcontainer/start-free.sh > .pentagi-state/start.log 2>&1 < /dev/null &
