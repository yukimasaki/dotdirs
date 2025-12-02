---
alwaysApply: true
title: testing-react-vitest
type: rule
tags: ["typescript", "react", "vitest", "next.js"]
---

# テストファイル作成ルール

## 概要

このプロジェクトでは、Vitest を使用してテストを実行します。
テスト環境はワークスペース設定により、ブラウザ環境（React Component）と Node 環境（非 React Component）に分離されています。

## 使用ライブラリ

### メインライブラリ

- **Vitest**: テストランナー・フレームワーク
- **@testing-library/react**: React コンポーネントテスト用
- **@testing-library/jest-dom**: DOM 要素のマッチャー
- **@testing-library/dom**: DOM 操作ユーティリティ
- **jsdom**: ブラウザ環境シミュレーション

### 開発ツール

- **@vitejs/plugin-react**: React サポート
- **vite-tsconfig-paths**: TypeScript パスエイリアス解決

## 設定ファイル

### vitest.workspace.ts

- ワークスペース設定でブラウザと Node 環境を分離
- 共通設定とそれぞれの環境固有設定を定義

### vitest.setup.ts

- `@testing-library/jest-dom`のセットアップ
- カスタムマッチャーの設定

### vitest.config.ts

- パスエイリアス設定（`@` -> `./`）
- 環境変数の読み込み設定

## テストファイルの配置

### 配置場所

各モジュールと同じディレクトリに `__tests__` ディレクトリを作成し、その中にテストファイルを配置します。

```
src/
  components/
    button/
      button.tsx
      __tests__/
        button.browser.spec.tsx
  utils/
    format.ts
    __tests__/
      format.node.spec.ts
```

## 命名規則

### React Component のテスト

- **対象**: `*.tsx` ファイル
- **命名**: `*.browser.spec.tsx`
- **環境**: jsdom（ブラウザ環境）
- **例**: `button.browser.spec.tsx`

### 非 React Component のテスト

- **対象**: `*.ts` ファイル
- **命名**: `*.node.spec.ts`
- **環境**: Node.js 環境
- **例**: `format.node.spec.ts`

## テスト環境の使い分け

### ブラウザ環境 (`*.browser.spec.tsx`)

- React コンポーネントのレンダリングテスト
- DOM 操作のテスト
- ユーザーインタラクションのテスト
- jsdom 環境で実行

### Node 環境 (`*.node.spec.ts`)

- ユーティリティ関数のテスト
- API 関数のテスト
- ビジネスロジックのテスト
- Node.js 環境で実行

## テスト実行コマンド

```bash
# 全テスト実行
make test
```

## 注意事項

### インポートパス

- パスエイリアス `@` が使用可能
- 相対パスよりも絶対パスを推奨

## ベストプラクティス

1. **単一責任**: 1 つのテストケースで 1 つの機能をテスト
2. **わかりやすい名前**: テストケース名は何をテストするか明確に
3. **AAA パターン**: Arrange（準備）、Act（実行）、Assert（検証）
4. **Mock の適切な使用**: 外部依存をモックして独立したテスト
5. **エラーケースのテスト**: 正常系だけでなく異常系もテスト
