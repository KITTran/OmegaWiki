#!/bin/bash

# SmartSync hook - tự động phát hiện máy đang chạy và sync đúng hướng
# Sử dụng hostname để phân biệt WSL vs Mac

# Lấy hostname hiện tại
hostname=$(hostname)

# Đường dẫn nguồn và đích
WSL_SOURCE="/home/tuank/mac_folder/pinnWiki/"
WSL_DEST="tuank@labpc:/home/tuank/mac_folder/pinnWiki/"
MAC_SOURCE="/Users/tuank/Documents/Projects/pinnWiki/"
MAC_DEST="tuank@kiets-macbook:/Users/tuank/Documents/Projects/pinnWiki/"

# Danh sách exclude chung
exclude_opts="--exclude='.claude/worktrees/' --exclude='*.tmp' --exclude='.venv' --exclude='.git'"

# Hàm sync từ WSL lên Mac
sync_to_mac() {
    echo "Syncing from WSL to Mac..."
    eval "rsync -avz --delete $exclude_opts \"$WSL_SOURCE\" \"$MAC_DEST\""
    echo '{"systemMessage": "Synced changes from WSL to Mac"}'
}

# Hàm sync từ Mac về labpc
sync_from_mac() {
    echo "Syncing from Mac to labpc..."
    eval "rsync -avz --delete $exclude_opts \"$MAC_SOURCE\" \"$WSL_DEST\""
    echo '{"systemMessage": "Synced changes from Mac to labpc"}'
}

# Logic phát hiện máy
if [[ "$hostname" == "labpc" ]] || [[ -d "/mnt/c" ]]; then
    # Máy này là labpc/WSL - sync lên Mac
    sync_to_mac
elif [[ "$hostname" == "kiets-macbook" ]] || [[ "$(uname)" == "Darwin" ]]; then
    # Máy này là Mac - sync về labpc
    sync_from_mac
else
    # Không xác định được - thông báo
    echo '{"systemMessage": "Could not determine machine type for sync", "continue": false}'
    exit 1
fi