---
type: command
name: quality-check
description: 型チェック、テスト、リントチェックの結果を簡潔に報告。自動修正は行わず、現状の品質を確認するコマンドです。
tools: find, fd, ls, tsc, vitest, lint
model: inherit
---

リント・型チェック・テストを実行（修正は行わない）

以下の手順で対象プロジェクト直下からコマンドを実行し、結果を報告してください。

1. `find` や `fd`、`ls` などで最も外側の `package.json` を探し、ディレクトリを特定する（例: `find . -maxdepth 2 -name package.json`）。
2. 該当ディレクトリへ移動する（例: `cd <project-root>`）。
3. 次の順にコマンドを実行する。
   - `yarn type-check`（または相当する型チェック用スクリプト）
   - `yarn test:run`（または相当するテストスクリプト）
   - `yarn lint`（自動修正オプションは付与しない）

注意:

- 自動修正は実行しないこと（`--fix` 等は使用禁止）
- 失敗があれば、その概要と該当ファイル/テスト名を列挙
- すべて成功なら `All passed` と簡潔に報告
