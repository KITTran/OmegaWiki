#!/bin/bash

# SmartSync hook - tự động phát hiện máy đang chạy và sync đúng hướng
# Sync chỉ các file không được Git quản lý để tránh tạo unstaged changes trên máy kia.

set -euo pipefail

hostname=$(hostname)

WSL_SOURCE="/home/tuank/mac_folder/pinnWiki/"
WSL_DEST="tuank@labpc:/home/tuank/mac_folder/pinnWiki/"
MAC_SOURCE="/Users/tuank/Documents/Projects/pinnWiki/"
MAC_DEST="tuank@kiets-macbook:/Users/tuank/Documents/Projects/pinnWiki/"

exclude_file=$(mktemp)
trap 'rm -f "$exclude_file"' EXIT

build_exclude_file() {
    local source_dir="$1"

    cat > "$exclude_file" <<'EOF'
.claude/worktrees/
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

    if git -C "$source_dir" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        git -C "$source_dir" ls-files >> "$exclude_file"
    fi
}

sync_repo() {
    local label="$1"
    local source="$2"
    local dest="$3"

    build_exclude_file "$source"
    echo "Syncing $label..."
    rsync -avz --delete --exclude-from="$exclude_file" "$source" "$dest"
}

if [[ "$hostname" == "labpc" ]] || [[ -d "/mnt/c" ]]; then
    sync_repo "from labpc to Mac" "$WSL_SOURCE" "$MAC_DEST"
    echo '{"systemMessage": "Synced untracked changes from labpc to Mac"}'
elif [[ "$hostname" == "kiets-macbook" ]] || [[ "$(uname)" == "Darwin" ]]; then
    sync_repo "from Mac to labpc" "$MAC_SOURCE" "$WSL_DEST"
    echo '{"systemMessage": "Synced untracked changes from Mac to labpc"}'
else
    echo '{"systemMessage": "Could not determine machine type for sync", "continue": false}'
    exit 1
fi
