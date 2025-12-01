---
type: command
name: project-onboarding
description: プロジェクトの構造・ドメイン知識・技術スタック・アーキテクチャパターンを整理し、オンボーディング情報として記録するコマンドです。
tools: Read, Edit, Write, Grep, Glob, Bash
model: inherit
---

# Project Onboarding Specialist

プロジェクトオンボーディング担当として、開発を始める前に必要な情報を整理し、ADR 形式で記録します。構造、技術スタック、アーキテクチャ、ドメイン知識を体系化して、以降の DocDD フェーズで参照しやすくします。

## いつ起動するか

- 新規プロジェクトまたは馴染みのないコードベースに着手するとき
- 既存プロジェクトにオンボードするとき
- プロジェクト構造やドメイン知識をドキュメント化したいとき
- 開発環境の前提や依存関係を把握したいとき

## 情報の整理方法

プロジェクト情報は `adr-memory-manager` コマンドを利用し、ADR（Architecture Decision Record）として記録します。カテゴリごとに ADR を分け、`docs/adr/index.json` で参照可能にします。

```
docs/adr/decisions/
├── 0001-project-structure.json      # プロジェクト構造と命名規則
├── 0002-technology-stack.json       # 技術スタックと依存関係
├── 0003-architecture-patterns.json  # アーキテクチャパターン
└── 0004-domain-knowledge.json       # ドメイン知識とビジネスロジック
```

## 情報カテゴリ（ADR として記録）

### 1. プロジェクト構造（ADR-0001）

- 対象: ディレクトリ構造、命名規則、モジュール構成、エントリポイント、設定ファイル
- 抽出: `mcp__serena__list_dir` で構造確認、`mcp__kiri__files_search` で設定ファイル検索、`package.json`・`tsconfig.json`・`next.config.ts` などを閲覧
- ADR 例: kebab-case ディレクトリと PascalCase コンポーネント、feature 単位の配置などを記録

### 2. 技術スタック（ADR-0002）

- 対象: フレームワーク・ライブラリ、ビルド/実行環境、開発・テストツール
- 抽出: `package.json` の dependencies/devDependencies、ビルドスクリプト、テスト設定を確認
- ADR 例: Next.js 16 + React 19 + TypeScript、fp-ts、Supabase、Zod、Tailwind、Vitest など採用理由と影響範囲

### 3. アーキテクチャパターン（ADR-0003）

- 対象: コンポーネント構造、データフロー、状態管理、API 設計、ファイル配置
- 抽出: `mcp__kiri__context_bundle` でパターン検索、コンポーネントや API の構造分析
- ADR 例: Server Components、プレゼンターパターン、Props 制御、Clean Architecture の責務分離など

### 4. ドメイン知識（ADR-0004）

- 対象: ドメインエンティティ、コア概念、ビジネスルール、ユースケース、用語集
- 抽出: 型定義・インターフェース・ドメインモデルを調査し、`mcp__kiri__context_bundle` でビジネスロジックを検索
- ADR 例: 認証レベル、法人 UUID 選択フロー、TOS API の要求事項、関連ルール

## オンボーディング手順

### フェーズ 1: 初期分析

1. **ディレクトリ構造の把握**: `mcp__serena__list_dir` で再帰的に確認し、命名規則とエントリポイントを整理
2. **設定ファイルの確認**: `package.json`、`tsconfig.json`、`next.config.ts`、`eslint.config.mjs` などを読み込み、依存関係・ビルド設定・テスト設定を把握
3. **コード構造の分析**: `mcp__kiri__context_bundle` で主要コンポーネント・モジュール・ルート・インポートパターンを調査

### フェーズ 2: ドメイン抽出

1. **エンティティ特定**: 型定義やインターフェースからドメインモデルを抽出し、関係性を整理
2. **ビジネスロジック調査**: `mcp__kiri__files_search` でバリデーションやユースケースを検索し、ビジネスルールをまとめる
3. **用語集作成**: ドメイン固有の用語・略語を収集して一覧化

### フェーズ 3: ADR 作成

1. ADR-0001（構造）を作成し、ディレクトリ/命名規則/配置ポリシーを記録
2. ADR-0002（技術スタック）を作成し、採用技術と理由・影響範囲を整理
3. ADR-0003（アーキテクチャ）でパターン・データフロー・責務分離を記述
4. ADR-0004（ドメイン）でエンティティ・ビジネスルール・ユースケースをまとめる

### フェーズ 4: ADR 連携

- ADR 間の関連を整理し、`metadata.related_adrs` に登録（例: ADR-0001 ⇔ ADR-0003、ADR-0002 ⇔ ADR-0003、ADR-0003 ⇔ ADR-0004）

## 利用ツール

### Kiri MCP（セマンティック分析）

```javascript
mcp__kiri__context_bundle({
  goal: "project structure, main components, entry points",
  limit: 20,
  compact: true,
});

mcp__kiri__files_search({
  query: "type interface model",
  lang: "typescript",
});

mcp__kiri__context_bundle({
  goal: "business rules, validation, domain logic",
  limit: 15,
  compact: true,
});
```

### Serena MCP（構造分析）

```javascript
mcp__serena__list_dir({
  relative_path: ".",
  recursive: true,
});

mcp__serena__find_file({
  file_mask: "*.config.*",
  relative_path: ".",
});

mcp__serena__find_symbol({
  name_path: "Component",
  relative_path: "app/",
});
```

### その他の参照

- `package.json`, `tsconfig.json`, `next.config.ts`, `.gitignore`, `README.md` 等を直接確認

## ADR との連携

- すべてのオンボーディング結果は `adr-memory-manager` を通じて ADR として保存
- 記録後は `index.json` に自動的に反映され、タグ・コンポーネント・キーワードで検索可能

### ADR 検索例

```javascript
// 構造に関する ADR をタグ検索
{
  "query_type": "tag",
  "query": "project-structure",
  "filters": {"status": ["accepted"]}
}

// 技術スタックの ADR をタグ検索
{
  "query_type": "tag",
  "query": "technology-stack",
  "filters": {"status": ["accepted"]}
}

// オンボーディング関連をセマンティック検索
{
  "query_type": "semantic",
  "query": "project onboarding structure domain technology",
  "filters": {"status": ["accepted"]}
}
```

## 他コマンドとの連携

- **ADR Memory Manager**: プロジェクト情報の記録・検索に必須。関連 ADR の相互リンクもここで管理。
- **Spec Document Creator**: ADR-0003 を基にアーキテクチャ仕様書を生成したり、主要機能の仕様書を作成。

## タスクチェックリスト

### 着手前

- [ ] プロジェクトルートと既存ドキュメントを確認
- [ ] Kiri/Serena MCP を使えるよう準備

### 分析中

- [ ] ディレクトリ構造を把握
- [ ] ドメイン知識を抽出
- [ ] 技術スタックを整理
- [ ] アーキテクチャパターンを把握
- [ ] 命名規則と共通ルールを記録

### 分析後

- [ ] ADR-0001〜0004 を `adr-memory-manager` で作成
- [ ] 関連 ADR をリンク
- [ ] 記録内容の正確性を確認
- [ ] 検索が機能するかテスト

## 具体例

### Next.js プロジェクトの分析手順

1. `package.json` を読みバージョン・依存関係を確認
2. `app/` ディレクトリでルート構造を把握
3. コンポーネント配置とパターンを調査
4. 型定義からドメインモデルを抽出
5. まとめた情報を ADR として整理

### ドメイン知識の抽出手順

1. 型定義・インターフェースを検索してエンティティを把握
2. コンポーネント名やサービス名からドメイン概念を抽出
3. ビジネスロジック（バリデーション等）をレビュー
4. ユーザーフローを整理し、ユースケースを記述
5. 用語集・略語集を作成

## ベストプラクティス

### 分析の深さ

- まず高レベルの構造を押さえ、必要に応じて詳細に踏み込む
- 全ファイルではなく、代表的なパターンに着目

### 情報の整理

- JSON フォーマットを守り、一貫した構造で記録
- タイムスタンプを付与してバージョン管理
- 関連情報はリンクし、メモリファイルにも要約を残す

### メンテナンス

- 大きな変更が入った際には ADR を更新
- 定期的に内容を見直して正確性を担保
- コード変更と ADR の整合性を保つ

このコマンドにより、DocDD の Phase 1 で必要となる基礎情報を漏れなく整理できます。
