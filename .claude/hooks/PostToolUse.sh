#!/bin/bash

# Hook PostToolUse để đảm bảo định dạng phương trình LaTeX trong các file markdown
file="$(jq -r '.tool_response.filePath // .tool_input.file_path')"
if [[ "$file" == *.md ]]; then
    sed -i 's/\[\[/$$/g; s/\]\]/$$/g; s/\[/(/g; s/\]/)/g' "$file"
    sed -i 's/\\\\(/\$/g; s/\\\\)/$/g' "$file"
fi