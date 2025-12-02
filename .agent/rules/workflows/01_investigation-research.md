---
alwaysApply: true
type: rule
name: 01_investigation-research
tags: ["Context7", "Kiri", "investigation", "research"]
---

# Investigation & Research (調査フェーズ) 【必須】

**使用ツール**: Context7 MCP, Kiri MCP

## 1. 既存コードベースの調査（Kiri MCP を使用）

Kiri MCP は Serena より高度な検索機能を提供します。セマンティック検索、フレーズ認識、依存関係分析などを活用してください。

### 1-1. コンテキスト自動取得（推奨）

```
mcp__kiri__context_bundle
goal: 'user authentication, login flow, JWT validation'
limit: 10
compact: true
```

- タスクに関連するコードスニペットを自動でランク付けして取得
- `goal`には具体的なキーワードを使用（抽象的な動詞は避ける）
- `compact: true`でトークン消費を 95%削減

### 1-2. 具体的なキーワード検索

```
mcp__kiri__files_search
query: 'validateToken'
lang: 'typescript'
path_prefix: 'src/auth/'
```

- 関数名、クラス名、エラーメッセージなど具体的な識別子で検索
- 広範な調査には`context_bundle`を使用

### 1-3. 依存関係の調査

```
mcp__kiri__deps_closure
path: 'src/auth/login.ts'
direction: 'inbound'
max_depth: 3
```

- 影響範囲分析（inbound）や依存チェーン（outbound）を取得
- リファクタリング時の影響調査に最適

### 1-4. コードの詳細取得

```
mcp__kiri__snippets_get
path: 'src/auth/login.ts'
```

- ファイルパスがわかっている場合に使用
- シンボル境界を認識して適切なセクションを抽出

## 2. ライブラリドキュメントの確認

- Context7 MCP を使用して最新のライブラリドキュメントを取得
- Next.js, React, その他使用するライブラリの最新情報を確認
- `mcp__context7__resolve-library-id` → `mcp__context7__get-library-docs` の順で実行

## 3. 既存決定の確認（ADR 参照）【必須】

**⚠️ 重要: このステップは必ず実行すること**

- **コード調査だけでは不十分**: `codebase_search`や Kiri MCP で既存パターンを確認しても、ADR 確認は別途必須
- **実装前に必ず確認**: 既存のアーキテクチャ決定に従うか、新しい決定が必要かを判断
- **ADR 確認方法**:
  1. `docs/adr/index.json`を確認して関連 ADR を特定
  2. 関連する ADR ファイル（`docs/adr/decisions/*.json`）を読み込む
  3. 特に以下のカテゴリの ADR を確認:
     - **アーキテクチャパターン**: コンポーネントの設計パターン、データ取得戦略、状態管理方法など
     - **ドメイン知識**: プロジェクト固有のドメインエンティティ、ビジネスロジック、必須実装要件など
       - **重要**: ドメイン知識 ADR に新規コンポーネント作成時の必須実装要件が記載されている場合、必ず確認
       - `affected_files`や`affected_components`を確認して、必要な登録や設定ファイルへの追加を特定
     - **プロジェクト構造**: ディレクトリ構造、命名規則、ファイル配置ルールなど
  4. **新規コンポーネント作成時の確認事項**:
     - デモコンポーネントやドキュメント実装が必要か確認
     - レジストリや設定ファイルへの登録が必要か確認
     - 必要なメタデータや設定の追加が必要か確認
  5. 実装が ADR の決定と一致しているか確認
  6. 新しい決定が必要な場合は`adr-memory-manager`エージェントを使用して記録

**ADR 確認のタイミング:**

- 初回確認（必須）
- Planning の前に再確認（推奨）
- Implementation の前に最終確認（推奨）

## 4. 調査結果の整理

- 既存パターンやコーディング規約を把握
- 再利用可能なコンポーネントやユーティリティを特定
- Kiri で取得したコンテキストを基に実装方針を決定
- **既存 ADR と照合して決定の一貫性を確認**（必須）

**完了チェックリスト:**

- [ ] Kiri MCP で関連コードを特定
- [ ] 必要なライブラリのドキュメントを確認
- [ ] 既存パターンと依存関係を把握
- [ ] **ADR を確認し、既存決定を理解**（必須 - コード調査とは別に実行）
- [ ] **ドメイン知識 ADR を確認し、新規コンポーネント作成時の必須実装要件を判断**（新規コンポーネント作成時は必須）
- [ ] 実装が ADR の決定と一致していることを確認
