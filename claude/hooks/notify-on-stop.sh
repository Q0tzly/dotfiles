#!/usr/bin/env bash
# Claude が応答を終えたタイミングで macOS の通知センターに通知を出す。
# ターミナルから離れているときに完了を気づくため。

set -u

osascript -e 'display notification "Claude が応答を終えました" with title "Claude Code" sound name "Glass"' >/dev/null 2>&1 || true

exit 0
