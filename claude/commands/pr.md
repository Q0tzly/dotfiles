---
description: 現在のブランチの全コミットから英語の PR を作成する
allowed-tools: Bash(git:*), Bash(gh pr create:*), Bash(gh pr view:*)
---

現在のブランチの全変更を要約して、英語の PR を作成してください。

手順:

1. ベースブランチを特定: `git remote show origin | grep "HEAD branch"` か、なければ `main`。
2. `git log --oneline <base>..HEAD` で全コミットを把握（最新コミットだけを見ない）。
3. `git diff <base>...HEAD --stat` で変更スコープを掴む。
4. 必要なら個別ファイルを `git diff` で読む。
5. PR タイトル（70 文字以内、簡潔に）と本文を作成。本文の構成:
   - **概要**: 何を・なぜ
   - **変更内容**: 箇条書きで主要変更点
   - **動作確認**: チェックリスト
6. `gh pr create --title "..." --body "$(cat <<'EOF' ... EOF)"` で作成。
7. 作成後、PR URL を表示。

注意:

- ブランチが未 push なら `git push -u origin <branch>` してから。
- main / master への PR は base を明示。
- 🤖 Generated with ... のような自動署名は付けない。
