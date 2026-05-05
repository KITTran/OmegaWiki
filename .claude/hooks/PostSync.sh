#!/bin/bash

# Hook PostSync để đồng bộ hóa thư mục pinnWiki với máy Mac sau khi tạo/sửa file
# Chỉ chạy khi có thay đổi trong thư mục wiki hoặc các thư mục con

# Thực hiện đồng bộ hóa
rsync -avz --delete --exclude='.claude/worktrees/' --exclude='*.tmp' --exclude='.venv' --exclude='.git' \
    "/home/tuank/mac_folder/pinnWiki/" \
    "tuank@100.125.70.98:/Users/tuank/Documents/Projects/pinnWiki/"
