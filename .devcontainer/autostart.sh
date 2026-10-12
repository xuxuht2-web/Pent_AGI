#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "$0")/.."
mkdir -p .pentagi-state
exec > .pentagi-state/start.log 2>&1
exec bash .devcontainer/start-free.sh
