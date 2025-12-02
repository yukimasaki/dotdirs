---
alwaysApply: true
type: rule
name: 02_architecture-design
tags: ["architecture", "design"]
---

# Architecture Design (アーキテクチャ設計) 【推奨：新機能/大規模変更時】

**使用エージェント**: component-refactoring-specialist, spec-document-creator, adr-memory-manager

**このフェーズをスキップできるケース:**

- 既存パターンに完全に倣う場合
- 1 ファイル以内の小さな修正
- ドキュメントやスタイルのみの変更

## 1. 技術的方針の決定

- ファイル配置、ディレクトリ構造の決定
- 状態管理の方法（useState, useContext, 外部ライブラリなど）
- データフローとコンポーネント間の関係性の設計
- API エンドポイントやデータ取得戦略の決定
- **重要な決定は `adr-memory-manager` で記録**

## 2. コンポーネント設計

- `component-refactoring-specialist` エージェントを使用
- コンポーネント分割の方針（責任の分離、単一責任原則）
- Props インターフェースの設計
- 再利用性と保守性を考慮した設計
- 既存コンポーネントとの整合性確認

## 3. 仕様書の作成

- `spec-document-creator` エージェントを使用して仕様書を作成
- 機能仕様、API 仕様、アーキテクチャ仕様など必要に応じて作成
- 既存コードからリバースエンジニアリングする場合は、コード分析機能を活用

## 4. アーキテクチャ決定の記録

- `adr-memory-manager` エージェントを使用して重要な決定を記録
- 決定のコンテキスト、根拠、代替案を記録
- 影響を受けるファイルやコンポーネントを記録
- 関連する ADR とリンク

## 5. パフォーマンス考慮事項

- フレームワーク固有の機能活用（Next.js の Cache Components、Server Components など）
- レンダリング戦略（SSR, SSG, ISR など）
- 画像最適化、コード分割など

**完了チェックリスト:**

- [ ] ファイル配置とディレクトリ構造を決定
- [ ] コンポーネント分割方針を決定
- [ ] 状態管理とデータフローを設計
- [ ] パフォーマンス戦略を検討
- [ ] 必要に応じて仕様書を作成
- [ ] 重要なアーキテクチャ決定を ADR として記録
