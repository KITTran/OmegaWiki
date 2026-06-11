#!/bin/bash

# StandardEq hook: normalize LaTeX delimiters trong file markdown
# - \(...\) → $...$ (inline)
# - \[...\] → $$...$$ (display)
# KHÔNG chạm vào [[wikilinks]] hay [markdown links]
file="$(jq -r '.tool_response.filePath // .tool_input.file_path')"
if [[ "$file" == *.md ]]; then
    sed -i 's/\\\\(/\$/g; s/\\\\)/$/g; s/\\\[/\$\$/g; s/\\\]/\$\$/g' "$file"
fi