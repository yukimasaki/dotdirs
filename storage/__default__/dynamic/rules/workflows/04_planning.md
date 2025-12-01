---
alwaysApply: true
type: rule
name: 04_planning
tags: ["planning", "TodoWrite"]
---

# Planning (計画立案) 【必須】

**使用ツール**: TodoWrite tool

**⚠️ 重要: Investigation & Research と UI / UX Design の確認**

- **Planning の前に必ず確認**:
  - **Investigation & Research の ADR 確認が完了しているか確認**（必須）
  - UI 変更がある場合は UI / UX Design が完了し、ユーザー承認を得ているか確認
- UI / UX Design で承認された改善案を実装計画に反映
- **ADR の決定に従った実装計画になっているか確認**

## 1. 実装計画の作成

- タスクを細分化し、実装順序を決定
- TodoWrite ツールで作業項目をトラッキング
- 各タスクの依存関係を明確化
- **UI / UX Design で承認された改善案をタスクに含める**
- **ADR の決定に従った実装方針を確認**

## 2. 計画のレビュー

- 不明確な要件や仕様の洗い出し
- 必要に応じて `AskUserQuestion` で確認
- **実装計画が ADR の決定と一致しているか確認**

**注意**: ExitPlanMode ツールは plan mode でのみ使用されます。通常の実装フローでは TodoWrite のみを使用してください。

**完了チェックリスト:**

- [ ] **Investigation & Research の ADR 確認が完了している**（必須）
- [ ] UI 変更がある場合、UI / UX Design が完了し承認を得ている
- [ ] TodoWrite で全タスクを登録
- [ ] UI / UX Design で承認された改善案をタスクに含めた
- [ ] **実装計画が ADR の決定と一致している**
- [ ] タスクの実行順序を決定
- [ ] 不明点をすべて解消
