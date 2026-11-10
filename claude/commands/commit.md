---
description: ステージ済みの差分から英語のコミットメッセージを作って commit する
allowed-tools: Bash(git status:*), Bash(git diff:*), Bash(git log:*), Bash(git commit:*), Bash(git add:*)
---

ステージ済みの差分を読み、このリポジトリの過去のコミット規約に倣って
英語の commit メッセージを作って commit してください。

手順:

1. `git status` で何がステージされているか確認。
2. `git diff --staged` で内容を読む。
3. `git log --oneline -20` で既存のスタイル（prefix の有無、語尾、長さ）を踏襲。
4. 1 行サマリ + 必要なら空行を挟んで本文。サマリは 50 文字以内目安、本文は「なぜ」を中心に。
5. `git commit -m` で commit。

注意:

- ステージされていない変更があっても、それは含めない。
- 何もステージされていなければ、その旨を伝えて終了。
- Co-Authored-By 行は付けない（個人リポジトリ前提）。
