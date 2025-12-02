---
alwaysApply: true
type: rule
name: 05_impementation
tags: ["implementation", "Serena"]
---

# Implementation (実装) 【必須】

**使用ツール**: Serena MCP (シンボルベース編集), Edit, Write, Read

**⚠️ 重要: Investigation & Research と UI / UX Design の確認**

- **実装前に必ず確認**:
  - **Investigation & Research の ADR 確認が完了しているか確認**（必須）
  - UI 変更がある場合、UI / UX Design で承認された改善案に従って実装する
- UI / UX Design をスキップして実装に進まない（UI 変更がある場合は必ず UI / UX Design を先に実行）
- **実装が ADR の決定と一致しているか確認**

## 1. コード実装（Serena MCP を使用）

Serena MCP はシンボルベースのコード編集に特化しています。Investigation & Research で Kiri で調査した内容を基に、Serena で正確に実装してください。

### 1-1. シンボルの置換

```
mcp__serena__replace_symbol_body
name_path: 'UserAuth/validateToken'
relative_path: 'src/auth/user.ts'
body: '新しい関数実装'
```

- 既存の関数、メソッド、クラスの本体を置換
- シンボルの name_path で正確に特定

### 1-2. 新しいコードの挿入

```
mcp__serena__insert_after_symbol
name_path: 'UserAuth'
relative_path: 'src/auth/user.ts'
body: '新しいメソッドの実装'
```

- 既存シンボルの後に新しいコードを挿入
- クラスへのメソッド追加、ファイル末尾への関数追加などに使用

### 1-3. シンボルのリネーム

```
mcp__serena__rename_symbol
name_path: 'validateToken'
relative_path: 'src/auth/user.ts'
new_name: 'verifyJwtToken'
```

- シンボルをプロジェクト全体でリネーム
- すべての参照が自動的に更新される

### 1-4. 参照の確認

```
mcp__serena__find_referencing_symbols
name_path: 'validateToken'
relative_path: 'src/auth/user.ts'
```

- 変更前に影響範囲を確認
- どのファイル・シンボルが参照しているか特定

## 2. コーディング規約の遵守

- TypeScript の型定義を厳密に
- 日本語コメントで意図を明確に
- ESLint、Prettier の設定に従う
- プロジェクト固有のパターンを踏襲
- **バレルインポート禁止**（`@/` alias を使用した個別インポート）

## 3. 進捗管理

- TodoWrite ツールでタスクを `in_progress` → `completed` に更新
- 一度に 1 つのタスクに集中

## 4. ADR の更新（実装完了後）

- `adr-memory-manager` エージェントを使用して実装内容を ADR に反映
- Architecture Design で記録した ADR に実装の詳細を追記
- 実際に実装されたファイル、コンポーネント、パターンを記録
- 実装時の変更点や追加の決定事項があれば記録
- コード例を追加して ADR をより実用的に

**完了チェックリスト:**

- [ ] **Investigation & Research の ADR 確認が完了している**（必須）
- [ ] Serena MCP でシンボルベース編集を実施
- [ ] TypeScript 型定義が厳密
- [ ] バレルインポート未使用
- [ ] 既存パターンに準拠
- [ ] **実装が ADR の決定と一致している**
- [ ] 日本語コメントで意図を説明
- [ ] TodoWrite で進捗更新済み
- [ ] 実装完了後、関連する ADR を更新・追記（新しい決定が必要な場合）
