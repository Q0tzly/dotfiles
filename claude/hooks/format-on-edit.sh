#!/usr/bin/env bash
# Edit/Write の後に、対象ファイルを拡張子で振り分けて整形する。
# 失敗してもツール本体の結果には影響させない（必ず exit 0）。

set -u

# stdin は PostToolUse の JSON。tool_input.file_path を抜き出す。
input=$(cat)
file=$(printf '%s' "$input" | /usr/bin/python3 -c 'import json,sys; d=json.load(sys.stdin); print(d.get("tool_input",{}).get("file_path",""))' 2>/dev/null)

[ -z "$file" ] && exit 0
[ ! -f "$file" ] && exit 0

case "$file" in
  *.ts|*.tsx|*.js|*.jsx|*.json|*.md|*.css|*.html|*.yml|*.yaml)
    command -v prettier >/dev/null 2>&1 && prettier --write "$file" >/dev/null 2>&1
    ;;
  *.go)
    command -v gofmt >/dev/null 2>&1 && gofmt -w "$file" >/dev/null 2>&1
    ;;
  *.rs)
    command -v rustfmt >/dev/null 2>&1 && rustfmt --edition 2021 "$file" >/dev/null 2>&1
    ;;
  *.py)
    command -v ruff >/dev/null 2>&1 && ruff format "$file" >/dev/null 2>&1
    ;;
  *.sh)
    command -v shfmt >/dev/null 2>&1 && shfmt -w "$file" >/dev/null 2>&1
    ;;
esac

exit 0
