# hooks/

ツール実行に紐づく自動処理。`settings.json` の `hooks` セクションから呼び出す。

## イベント

| イベント | 発火タイミング |
|---|---|
| `PreToolUse` | ツール実行直前。exit 1 で実行をブロックできる |
| `PostToolUse` | ツール実行直後。自動フォーマットなどに |
| `UserPromptSubmit` | ユーザー入力直後 |
| `Stop` | Claude が応答を終えたとき。通知音などに |
| `Notification` | 通知発生時 |

## 設定例（settings.json 側）

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          { "type": "command", "command": "/path/to/claude/hooks/format-on-edit.sh" }
        ]
      }
    ]
  }
}
```

`matcher` は対象ツール名の正規表現。`""` で全マッチ。

## このリポジトリのスクリプト

| スクリプト | 用途 |
|---|---|
| `format-on-edit.sh` | 編集後に拡張子に応じて整形（prettier / gofmt / rustfmt） |
| `notify-on-stop.sh` | 応答完了時に macOS 通知 |

## 追加するときの方針

- 入出力は JSON（stdin から受け取り、stdout に返す）。
- 失敗時に Claude の作業を止めたくないものは必ず `|| true` か exit 0 で抜ける。
- 長時間ブロックする処理を入れない（フックは毎ツール呼び出しで走る）。
