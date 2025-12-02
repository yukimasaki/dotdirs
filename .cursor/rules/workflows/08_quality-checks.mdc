---
alwaysApply: true
type: rule
name: 08_quality-checks
tags: ["quality", "type-check", "lint"]
---


# Quality Checks (品質チェック) 【必須】

**使用コマンド**: quality-check

## 1. 静的解析とテスト実行

- `quality-check` エージェントを使用
- 以下のチェックを一括で実行し、現状の品質を確認
  - 型チェック (`yarn tsc --noEmit`)
  - テスト実行 (`yarn vitest run`)
  - Lint チェック (`yarn eslint`)

## 2. エラーの修正

- エラーが発生した場合は修正して再実行
- 自動修正 (`--fix`) は使用せず、手動で修正すること
- すべてのチェックがパスするまで繰り返す

**完了チェックリスト:**

- [ ] `quality-check` エージェントを実行した
- [ ] 型チェックが通る
- [ ] Lint エラーがゼロ
- [ ] すべてのテストが通る
- [ ] ビルドが成功

**トラブルシューティング:**

- エラーが続く場合は Implementation に戻って修正
- 必要に応じて `mcp__ide__getDiagnostics` で詳細確認
