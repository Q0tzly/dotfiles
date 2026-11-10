# output-styles/

応答の出力スタイルをカスタマイズする。`/output-style` で切り替える。

## 既定スタイル

- `default` — 標準
- `explanatory` — 説明多め（学習向け）
- `concise` — 簡潔（既存タスクを淡々と）

## カスタムスタイルの定義

Markdown で 1 ファイル 1 スタイル:

```markdown
---
name: my-style
description: いつ使うか
---

ここに「Claude はこう応答する」というシステム指示を書く。
- 文体（です・ます / だ・である）
- フォーマット（箇条書き多め / 散文 / 表形式）
- 含めるもの・省くもの
```

公式: https://docs.claude.com/en/docs/claude-code/output-styles
