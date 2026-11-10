# commands/

カスタムスラッシュコマンド。`~/.claude/commands/` または各プロジェクトの `.claude/commands/` に置くと `/<ファイル名>` で呼べる。

## フォーマット

Markdown ファイル。先頭に YAML frontmatter を書ける:

```markdown
---
description: コマンドの説明（一覧で表示される）
argument-hint: <引数の形>     # 任意
allowed-tools: Bash(git:*)    # 任意。指定したツールだけ自動許可
---

ここに本文。Claude へのプロンプトとして渡される。
`$ARGUMENTS` で引数を埋め込める。
```

## このリポジトリの一覧

| コマンド | 用途 |
|---|---|
| `/commit` | ステージ済み差分から日本語コミット |
| `/pr` | ブランチ全体から日本語 PR 作成 |
| `/explain <対象>` | コード・概念の構造的解説 |
| `/plan <タスク>` | 実装計画だけ立てる |

## 追加するときの方針

- 同じプロンプトを 3 回以上書きそうになったらコマンド化を検討。
- frontmatter の `description` は一覧で読まれる。動詞始まりで具体的に。
- `allowed-tools` を指定すると権限プロンプトが減る。ただし広げすぎると事故るので最小限に。
