---
alwaysApply: true
type: mcp-reference
name: kiri-mcp
tags: ["mcp", "kiri", "code-search", "context-extraction", "investigation"]
---

# Kiri MCP

コードベース検索とコンテキスト抽出に特化した MCP です。Serena よりも高度な検索機能を提供します。

## 主な機能

### 1. コンテキストバンドル取得（最重要）

```
mcp__kiri__context_bundle
goal: 'User authentication flow, JWT token validation'
limit: 7  # 取得するスニペット数（デフォルト: 7）
compact: true  # メタデータのみ（デフォルト: true、トークン消費を95%削減）
```

**説明**: タスクや質問に関連するコードスニペットを AI が自動的にランク付けして取得します。

**特徴**:

- フレーズ認識: `page-agent`, `user_profile` などの複合語を単一フレーズとして認識
- パスベーススコアリング: キーワードがファイルパスに含まれるとスコアが上がる
- ファイルタイプ優先度: 実装ファイルをドキュメントより優先（設定可能）
- 依存関係分析: インポート関係を考慮
- セマンティック類似度: クエリとの構造的類似性でランク付け

**goal パラメータの書き方**:

- ✅ 良い例: `'User authentication flow, JWT token validation'`
- ✅ 良い例: `'Canvas page routing, API endpoints, navigation patterns'`
- ✅ 良い例: `'page-agent Lambda handler implementation'`
- ❌ 悪い例: `'Understand how canvas pages are accessed'` (抽象的な動詞)
- ❌ 悪い例: `'understand'` (単語のみ)
- ❌ 悪い例: `'fix bug'` (具体性がない)

**compact モードの使い方**:

- `compact: true`: メタデータのみ（path, range, why, score）、トークン消費を 95%削減
- `compact: false`: コードプレビューも含む

**推奨ワークフロー**（2 段階アプローチ）:

1. `context_bundle({goal: 'auth handler', compact: true, limit: 10})` → 候補リスト取得
2. 結果からパスとスコアを確認
3. `snippets_get({path: result.context[0].path})` → 必要なファイルのみ取得

### 2. ファイル検索

```
mcp__kiri__files_search
query: 'validateToken'  # 具体的な関数名、クラス名、エラーメッセージ
lang: 'typescript'  # オプション: 言語でフィルタ
ext: '.ts'  # オプション: 拡張子でフィルタ
path_prefix: 'src/auth/'  # オプション: パスプレフィックスでフィルタ
limit: 50  # 最大結果数（デフォルト: 50）
```

**説明**: 具体的なキーワードや識別子でファイルを検索します。

**いつ使うか**:

- ✅ 特定の関数名、クラス名がわかっている: `query: 'validateToken'`
- ✅ 正確なエラーメッセージ: `query: 'Cannot read property'`
- ✅ 特定のインポートパターン: `query: 'import { jwt }'`
- ❌ 広範な調査: `'understand authentication'` → `context_bundle`を使用

### 3. コードスニペット取得

```
mcp__kiri__snippets_get
path: 'src/auth/login.ts'
start_line: 10  # オプション
end_line: 50  # オプション
```

**説明**: 特定のファイルからコードスニペットを取得します。シンボル境界（関数、クラス、メソッド）を認識して適切なセクションを抽出します。

**使い方**:

- ファイルパスがわかっている場合に使用
- `start_line`を指定すると、その行を含む最も関連性の高いシンボルを取得
- ファイル全体を読み込むよりトークン効率が良い

### 4. セマンティック再ランク

```
mcp__kiri__semantic_rerank
text: 'user authentication flow'
candidates: [
  {path: 'src/auth/login.ts', score: 0.8},
  {path: 'src/auth/register.ts', score: 0.7}
]
k: 5  # 上位N件を返す
```

**説明**: ファイル候補リストをセマンティック類似度で再ランク付けします。

**いつ使うか**:

- `files_search`の結果を絞り込みたい場合
- 複数の候補から最も関連性の高いものを選びたい場合

**注意**: `context_bundle`は内部で自動的にセマンティックランキングを行うため、併用は不要です。

### 5. 依存関係クロージャ

```
mcp__kiri__deps_closure
path: 'src/utils.ts'
direction: 'inbound'  # 'inbound' または 'outbound'
max_depth: 3  # トラバース深度（デフォルト: 3）
include_packages: false  # 外部パッケージも含める
```

**説明**: ファイルの依存関係グラフをトラバースします。

**direction**:

- `inbound`: このファイルに依存しているファイルを取得（影響範囲分析）
- `outbound`: このファイルが依存しているファイルを取得（依存チェーン）

**いつ使うか**:

- リファクタリング時の影響範囲を調べる
- モジュール境界を理解する
- 循環依存を発見する
- 変更が影響するファイルを特定する

**例**:

```
# src/utils.tsを変更した場合、どのファイルが影響を受けるか
mcp__kiri__deps_closure
path: 'src/utils.ts'
direction: 'inbound'
max_depth: 3
```

## Kiri vs Serena

| 機能                 | Kiri                                        | Serena                          |
| -------------------- | ------------------------------------------- | ------------------------------- |
| **コードベース検索** | ⭐ 高度（セマンティック検索、フレーズ認識） | 基本（パターンマッチング）      |
| **コンテキスト抽出** | ⭐ 自動ランク付け、トークン効率的           | 手動でシンボル検索              |
| **シンボル操作**     | ❌ なし                                     | ⭐ あり（編集、リネーム、挿入） |
| **依存関係分析**     | ⭐ グラフトラバース                         | 参照検索のみ                    |
| **メモリ機能**       | ❌ なし                                     | ⭐ あり                         |

**推奨使い分け**:

- **01_investigation-research（調査）**: Kiri を優先（`context_bundle`, `files_search`）
- **05_impementation（実装）**: Serena を使用（`replace_symbol_body`, `insert_after_symbol`など）

## 使用例

### 例 1: 新機能の調査

```
# 1. 関連コードを自動取得
mcp__kiri__context_bundle
goal: 'user authentication, login flow, session management'
limit: 10
compact: true

# 2. 必要なファイルの詳細を取得
mcp__kiri__snippets_get
path: 'src/auth/login.ts'
```

### 例 2: バグ修正の影響範囲調査

```
# 1. バグのあるファイルを検索
mcp__kiri__files_search
query: 'calculateTotal'
lang: 'typescript'

# 2. 依存関係を調査（影響範囲）
mcp__kiri__deps_closure
path: 'src/utils/calculations.ts'
direction: 'inbound'
max_depth: 2
```

### 例 3: 特定エラーメッセージの調査

```
# エラーメッセージで検索
mcp__kiri__files_search
query: 'TypeError: Cannot read property'
limit: 20
```

**使用タイミング**: 01_investigation-research（調査フェーズ）で積極的に活用してください。

