#!/bin/bash

# SmartSync hook — push untracked/raw/wiki state from this machine to a peer.
#
# Configuration lives in `.claude/hooks/smartsync.conf` (gitignored, per-machine).
# Each machine declares its own LOCAL source and the REMOTE peer to push to.
# That file is created by `/setup` when the user opts in. Template lives in
# `config/smartsync.conf.example`.
#
# Expected variables in smartsync.conf:
#   SMARTSYNC_LOCAL="/abs/path/to/repo/"            # optional; auto-detected if unset
#   SMARTSYNC_REMOTE="user@host:/abs/path/to/repo/" # required
#
# The hook is a no-op (silent) when the config file is missing — that is the
# default state for a fresh clone.

set -euo pipefail

# Resolve repo root from this script's location (.claude/hooks/SmartSync.sh).
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
CONF_FILE="$SCRIPT_DIR/smartsync.conf"

if [[ ! -f "$CONF_FILE" ]]; then
    # No config → user did not opt in. Stay silent so the hook is a no-op.
    exit 0
fi

# shellcheck disable=SC1090
source "$CONF_FILE"

SMARTSYNC_LOCAL="${SMARTSYNC_LOCAL:-$REPO_ROOT/}"
# Ensure trailing slash on LOCAL so rsync mirrors contents (not the dir itself).
[[ "$SMARTSYNC_LOCAL" == */ ]] || SMARTSYNC_LOCAL="$SMARTSYNC_LOCAL/"

if [[ -z "${SMARTSYNC_REMOTE:-}" ]]; then
    echo '{"systemMessage": "SmartSync: smartsync.conf is missing SMARTSYNC_REMOTE", "continue": false}'
    exit 1
fi

if [[ ! -d "$SMARTSYNC_LOCAL" ]]; then
    echo "{\"systemMessage\": \"SmartSync: local source not found: $SMARTSYNC_LOCAL\", \"continue\": false}"
    exit 1
fi

exclude_file=$(mktemp)
trap 'rm -f "$exclude_file"' EXIT

build_exclude_file() {
    local source_dir="$1"

    cat > "$exclude_file" <<'EOF'
.claude/worktrees/
.claude/hooks/smartsync.conf
.obsidian/
*.tmp
.venv/
.git/
__pycache__/
*.pyc
.pytest_cache/
.mypy_cache/
.ruff_cache/
.cache/
EOF

    # Exclude everything Git already tracks except raw/ and wiki/ — those two
    # carry working state worth mirroring even though they are tracked.
    if git -C "$source_dir" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        git -C "$source_dir" ls-files | grep -Ev '^(raw|wiki)/' >> "$exclude_file"
    fi
}

build_exclude_file "$SMARTSYNC_LOCAL"
echo "Syncing $SMARTSYNC_LOCAL -> $SMARTSYNC_REMOTE ..."
rsync -avz --delete --exclude-from="$exclude_file" "$SMARTSYNC_LOCAL" "$SMARTSYNC_REMOTE"
echo "{\"systemMessage\": \"SmartSync: pushed to $SMARTSYNC_REMOTE\"}"
