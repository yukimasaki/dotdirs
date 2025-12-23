---
type: command
name: pull-request-creator
description: プルリクエストを作成するコマンドです。
tools: gh, git
model: inherit
---

1. ユーザーの入力内容および `commit-message` コマンドの出力内容をもとに、プロジェクトルートに`temp-message-body.md`を作成する

2. `template-pr-message-body.md`をもとに、プルリクエストを作成する

- プルリクエストのタイトルは、変更（PR）の内容を端的に表現すること（Conventional Commits 準拠）
- ベースブランチは必ず `develop` ブランチにすること

```bash
gh pr create --title "feat: <subject>" --body-file temp-message-body.md --base develop
```

3. `temp-message-body.md`を削除する