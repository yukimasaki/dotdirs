---
type: command
name: adr-memory-manager
description: ADR（Architecture Decision Record）を機械可読に記録・検索・管理するためのコマンドです。
tools: Read, Edit, Write, Grep, Glob, Bash
model: inherit
---

# ADR メモリーマネージャー

ADR メモリーマネージャーは、アーキテクチャ上の意思決定を JSON 形式で自動記録し、効率的に検索・参照できるよう整理する役割を持ちます。人間が読むことよりも、AI ツールから扱いやすい構造化データとして管理することを重視します。

## いつ利用するか

- 新しいアーキテクチャ判断・設計方針を決定したとき
- 過去の決定内容や背景を参照したいとき
- コードに現れているパターンの理由を知りたいとき
- リファクタリングで既存の決定が有効か確認するとき
- オンボーディングでプロジェクトの設計判断を把握したいとき

## ADR の保存構成

ADR は以下のディレクトリ構造で保存します。AI から機械的に処理できるよう、決定ごとに JSON ファイルへまとめます。

```
docs/
└── adr/
    ├── index.json              # すべての ADR を集約したインデックス（機械可読）
    ├── decisions/              # 個別の ADR ファイル
    │   ├── 0001-decision-name.json
    │   ├── 0002-another-decision.json
    │   └── ...
    └── embeddings/             # （任意）セマンティック検索用ベクトル
        └── ...
```

## ADR ファイル形式（JSON）

## 記述する言語

- **英語で固定する項目**: JSON のフィールド名、`id`、`status` の値（`accepted` / `proposed` / `deprecated` / `superseded`）、`metadata.tags`、`search_keywords`（英語小文字推奨）
- **日本語で記述してよい項目**: `title`、`context` 内の各フィールド、`decision` 内の説明要素（`summary`・`details`・`alternatives`・`rationale`・`consequences` など）、`implementation` の説明文、その他の説明系フィールド（`metadata.author` などの文字列値）

各 ADR は次の JSON 形式で記録します。フィールド名は英語で統一し、値は日本語でも問題ありません。

```json
{
  "id": "ADR-0001",
  "timestamp": "2024-11-09T12:00:00Z",
  "title": "意思決定のタイトル",
  "status": "accepted|proposed|deprecated|superseded",
  "context": {
    "problem": "この判断で解決したい課題を記述します。",
    "constraints": [
      "遵守すべき制約条件を列挙します。",
      "システム全体へ影響する制約事項など"
    ],
    "requirements": [
      "満たすべき要件を列挙します。",
      "利害関係者が求める品質要件など"
    ]
  },
  "decision": {
    "summary": "意思決定の要約を簡潔に説明します。",
    "details": "採用した方針の背景や詳細、設計上の考慮点を具体的に記述します。",
    "alternatives": [
      {
        "option": "検討した代替案の名称",
        "pros": ["代替案の利点を記述します。", "他案と比較した強みなど"],
        "cons": [
          "代替案の欠点や懸念点を記述します。",
          "導入コストや運用負荷など"
        ],
        "rejected": true,
        "reason": "採用しなかった理由を記述します。"
      }
    ],
    "rationale": "この意思決定を採用した根拠や判断材料を説明します。",
    "consequences": [
      "この判断による影響・副作用を列挙します。",
      "将来的なフォローアップ事項など"
    ]
  },
  "implementation": {
    "affected_files": ["path/to/file1.ts", "path/to/file2.ts"],
    "affected_components": ["Component1", "Component2"],
    "code_patterns": [
      "採用したコードパターンの説明",
      "再利用が必要なユーティリティなど"
    ],
    "examples": [
      {
        "file": "path/to/example.ts",
        "line_start": 10,
        "line_end": 20,
        "description": "判断内容を反映したコード例の概要を記述します。"
      }
    ]
  },
  "metadata": {
    "tags": ["tag1", "tag2", "tag3"],
    "related_adrs": ["ADR-0002", "ADR-0003"],
    "supersedes": null,
    "superseded_by": null,
    "author": "AI Assistant",
    "reviewers": []
  },
  "search_keywords": ["keyword1", "keyword2", "synonym1", "synonym2"],
  "vector_embedding": null
}
```

## インデックスファイル形式

`index.json` にはすべての ADR の概要と索引情報をまとめます。タグ・コンポーネントなどで検索できるようにします。

```json
{
  "version": "1.0",
  "last_updated": "2024-11-09T12:00:00Z",
  "adrs": [
    {
      "id": "ADR-0001",
      "title": "Decision Title",
      "status": "accepted",
      "timestamp": "2024-11-09T12:00:00Z",
      "tags": ["tag1", "tag2"],
      "keywords": ["keyword1", "keyword2"],
      "affected_components": ["Component1"],
      "file_path": "docs/adr/decisions/0001-decision-name.json"
    }
  ],
  "indices": {
    "by_tag": {
      "tag1": ["ADR-0001", "ADR-0002"],
      "tag2": ["ADR-0001"]
    },
    "by_component": {
      "Component1": ["ADR-0001"],
      "Component2": ["ADR-0002"]
    },
    "by_status": {
      "accepted": ["ADR-0001"],
      "deprecated": ["ADR-0002"]
    }
  }
}
```

## 基本オペレーション

### 1. ADR を記録する

**記録するタイミング**

- アーキテクチャに影響する重要な判断を下したとき
- 新しいコードパターンや設計方針を採用したとき
- 技術選定やライブラリ構成を決定したとき

**手順**

1. 判断の背景・影響範囲を整理する
2. 必要な情報（関連ファイル、影響するコンポーネント、代替案など）を洗い出す
3. ADR JSON を作成し、`docs/adr/decisions/` に保存
4. `docs/adr/index.json` にメタ情報を追記
5. 関連 ADR がある場合は `metadata.related_adrs` を更新

### 2. ADR を検索する

**主な検索軸**

- ID: `ADR-0001` のように直接指定
- タグ: `authentication`, `architecture` など
- コンポーネント: 影響を受けるモジュール名で絞り込み
- キーワード: `search_keywords` に登録した語句で検索
- ファイル: 特定ファイルに関係する ADR を調べる

**クエリ例**

```json
{
  "query_type": "semantic|exact|tag|component|file",
  "query": "user authentication pattern",
  "filters": {
    "status": ["accepted"],
    "tags": ["authentication"],
    "date_range": {
      "from": "2024-01-01",
      "to": "2024-12-31"
    }
  },
  "limit": 10
}
```

### 3. ADR を更新する

**更新が必要になるケース**

- 決定が別の方針に置き換えられた
- ステータスが `proposed` → `accepted` → `deprecated` のように変化した
- 新しい知見や影響範囲が判明した

**手順**

1. 既存の ADR を読み込み、変更箇所を反映
2. `timestamp` を更新
3. `index.json` および関連する ADR のリンク情報を更新

### 4. ADR 間の関連付け

- `supersedes`: この ADR が以前の ADR を置き換える場合に設定
- `related_adrs`: 関連する判断がある場合に相互リンク
- `depends_on`: この決定が他の ADR に依存している場合に設定
- `conflicts_with`: 競合する判断が存在する場合に設定

## コード調査ツールとの連携

### Kiri MCP による文脈抽出

```javascript
mcp__kiri__context_bundle({
  goal: "architectural decision, design pattern, technology choice",
  limit: 20,
  compact: true,
});
```

### Serena MCP によるパターン検出

```javascript
mcp__serena__find_symbol({
  name_path: "pattern_name",
  relative_path: "src/",
});

mcp__serena__find_referencing_symbols({
  name_path: "pattern_name",
  relative_path: "src/pattern.ts",
});
```

## 自動化ワークフロー

1. **意思決定の検出**: コード変更や議論から新しい判断を特定
2. **文脈抽出**: Kiri/Serena MCP を使って関連コード・影響範囲を洗い出し
3. **ADR 作成**: JSON 形式で決定内容を記録
4. **保存・索引更新**: `decisions/` へ保存し、`index.json` を更新
5. **検証**: 既存 ADR と矛盾が無いか、JSON の整合性を確認

## クエリ例

### コンポーネント別の ADR を検索

```javascript
{
  "query_type": "component",
  "query": "UserAuth",
  "filters": {
    "status": ["accepted"]
  }
}
```

### 認証関連の決定をセマンティック検索

```javascript
{
  "query_type": "semantic",
  "query": "how to handle user authentication",
  "filters": {
    "status": ["accepted", "proposed"]
  },
  "limit": 5
}
```

### 特定ファイルに影響する ADR を検索

```javascript
{
  "query_type": "file",
  "query": "src/auth/user.ts",
  "filters": {}
}
```

## ADR のライフサイクル

1. **Proposed**: 提案段階
2. **Accepted**: 実装済みで正式採用
3. **Deprecated**: 推奨されなくなった
4. **Superseded**: 別の ADR に置き換えられた

## 記録時のベストプラクティス

- 判断が固まり次第、可能な限り早く記録する
- 影響範囲（ファイル・コンポーネント・コード例）を具体的に記述する
- 代替案・採用理由・副作用を明示する
- タグと検索キーワードを十分に登録し、検索性を高める
- 関連する ADR を相互リンクして追跡しやすくする

## 検索時のベストプラクティス

- 幅広く調べたい場合は `semantic` 検索を利用
- 特定 ID やタグが分かっている場合は `exact`・`tag` を使用
- ステータスでフィルターして現行方針のみ抽出
- 関連 ADR も併せて確認し、判断の背景を把握
- 旧方針（deprecated/superseded）の履歴も参考にする

## タグ・キーワードの付け方

- 一貫した命名（英語小文字ハイフン区切りなど）を徹底
- 同義語や略語も `search_keywords` に登録
- コンポーネントやレイヤー名、外部サービス名などもタグ化

## ファイル命名規則

- `{番号}-{kebab-case-タイトル}.json`
- 番号は 0 埋め（例: 0001, 0002）
- 例: `0001-use-server-components.json`, `0002-implement-presenter-pattern.json`

## タスクチェックリスト

### ADR を記録する前

- [ ] 判断ポイントを明確化
- [ ] Kiri/Serena MCP で文脈・依存関係を把握
- [ ] 関連 ADR の有無を確認
- [ ] 番号とファイル名を決定

### 記録中

- [ ] problem / constraints / requirements を整理
- [ ] decision（要約・詳細・代替案・理由）を記入
- [ ] 影響ファイル・コンポーネント・コード例を洗い出し
- [ ] タグと検索キーワードを登録
- [ ] 関連 ADR をリンク

### 記録後

- [ ] `docs/adr/decisions/` に保存
- [ ] `docs/adr/index.json` を更新
- [ ] JSON の整合性を確認
- [ ] 重複や矛盾がないかチェック

### ADR を検索・参照するとき

- [ ] 検索タイプとフィルターを決める
- [ ] index.json から候補を抽出
- [ ] 必要な ADR を読み込み、背景と影響を確認
- [ ] 追加の判断が必要なら新しい ADR を作成

## 開発フローとの連携

### Phase 1: 調査

- 関連 ADR を検索して既存方針を把握
- 設計パターンや利用ライブラリの判断を確認

### Phase 2: アーキテクチャ設計

- 新しい判断があれば ADR を作成
- 既存 ADR と矛盾がないか検証

### Phase 5: 実装

- ADR に記載された方針に従ってコードを実装
- 新しい判断が生まれた場合は追加で記録

### Phase 7: コードレビュー

- 実装が ADR に準拠しているか確認
- 方針が変わった場合は ADR を更新

## 拡張性

新しいメタデータを追加したい場合は、JSON スキーマと `index.json` の構造を更新します。例:

- 新しい `query_type` を追加して検索軸を増やす
- `metadata` に新しいフィールドを定義する
- `indices` に追加の分類キーを導入する

## 例

### Server Components 採用の ADR

```json
{
  "id": "ADR-0001",
  "timestamp": "2024-11-09T12:00:00Z",
  "title": "データ取得に Next.js Server Components を採用する",
  "status": "accepted",
  "context": {
    "problem": "クライアント側でのデータ取得によりローディングが発生し、SEO に悪影響が出ている。",
    "constraints": [
      "Next.js 16 を利用すること",
      "React Server Components が利用可能であること"
    ],
    "requirements": [
      "SSR を前提とした高速レスポンス",
      "SEO 最適化",
      "パフォーマンス向上"
    ]
  },
  "decision": {
    "summary": "データ取得は useEffect ではなく Server Components で async/await を用いて実行する。",
    "details": "アプリケーション全体でデータ取得を Server Components に統一し、初期表示時のローディングを排除する。クライアント側では描画ロジックのみに集中させる。",
    "alternatives": [
      {
        "option": "useEffect を用いたクライアント側データ取得",
        "rejected": true,
        "reason": "ローディング表示と SEO 低下を招くため採用できない。"
      }
    ],
    "rationale": "Server Components を用いることで、初期表示速度と SEO を両立しつつ、状態管理を簡潔に保てる。",
    "consequences": [
      "クライアント側でのローディング表示が不要になる",
      "SEO が向上する",
      "コード構造が簡潔になる"
    ]
  },
  "implementation": {
    "affected_files": ["app/**/page.tsx", "app/**/layout.tsx"],
    "affected_components": ["All page components"],
    "code_patterns": [
      "async function Page() { const data = await fetchData(); }"
    ]
  },
  "metadata": {
    "tags": ["nextjs", "server-components", "data-fetching", "ssr"],
    "related_adrs": [],
    "search_keywords": [
      "server components",
      "data fetching",
      "async await",
      "SSR",
      "SEO"
    ]
  }
}
```

### 認証方針に関する検索例

```javascript
{
  "query_type": "semantic",
  "query": "authentication implementation",
  "filters": {
    "status": ["accepted"],
    "tags": ["authentication"]
  }
}
```
