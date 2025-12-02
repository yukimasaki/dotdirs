---
alwaysApply: true
title: clean-architecture-bulletproof-react
type: rule
tags:
  ["typescript", "react", "next.js", "clean-architecture", "bulletproof-react"]
---

# プロジェクト設計原則

本プロジェクトでは、以下の設計原則に基づいて開発を行います。

## 1. クリーンアーキテクチャ（レイヤー分離）

### レイヤー構成

4 層のアーキテクチャで依存関係を管理します：

```
Presentation Layer → Application Layer → Domain Layer → Infrastructure Layer
```

### 各レイヤーの責務

- **Presentation Layer（プレゼンテーション層）**

  - UI の表示とユーザーインタラクションの処理
  - Next.js App Router、React コンポーネント
  - Application Layer のみに依存

- **Application Layer（アプリケーション層）**

  - ユースケースの実装とフローの制御
  - Next.js Route Handlers、API Routes
  - Domain Layer と Infrastructure Layer に依存

- **Domain Layer（ドメイン層）**

  - ビジネスロジックとドメインモデル
  - 純粋関数、型定義、`fp-ts`（Either、Option、TaskEither）
  - **外部に依存しない（純粋関数）**

- **Infrastructure Layer（インフラストラクチャ層）**
  - 外部サービスとの連携（Supabase Auth、Keycloak）
  - Supabase Client、HTTP クライアント
  - Domain Layer に依存

### 依存関係の方向性

- Domain Layer は外部に依存しない（純粋関数）
- 依存関係は内側から外側への一方向のみ
- 外側のレイヤーは内側のレイヤーに依存可能

## 2. DDD（ドメイン駆動設計）

### ドメインモデルの分離

ドメインモデルは以下のように分離します：

- **値オブジェクト（Value Objects）**: 不変性を保証し、値の等価性で比較される（例: `AuthLevel`）
- **エンティティ（Entities）**: 識別子を持ち、ライフサイクルを持つ（例: `User`、`Organization`）
- **ドメインモデル（集約）**: ビジネスロジックを含む複合的なモデル（例: `AuthState`）
- **ドメインサービス**: ビジネスロジックを実装する純粋関数

### ディレクトリ構成

```
features/
└── {feature-name}/
    ├── domain/
    │   ├── value-objects/    # 値オブジェクト
    │   ├── entities/         # エンティティ
    │   ├── models/           # ドメインモデル（集約）
    │   ├── services/         # ドメインサービス
    │   └── use-cases/        # ユースケース
    ├── application/
    │   ├── services/         # アプリケーションサービス
    │   └── repositories/     # リポジトリインターフェース
    ├── infrastructure/
    │   ├── repositories/     # リポジトリ実装
    │   └── clients/          # 外部クライアント
    └── presentation/
        ├── components/       # コンポーネント
        └── hooks/            # カスタムフック
```

## 3. 関数型ドメインモデリング（FDM）

### 原則

- **純粋関数によるビジネスロジック**: 副作用を含まない純粋関数で実装
- **副作用の分離**: 外部依存（API 呼び出し、DB アクセスなど）は Infrastructure Layer に集約
- **参照透過性**: 同じ入力に対して常に同じ出力を返す

### 実装方針

- ドメイン層のロジックは純粋関数として実装
- 外部依存が必要な場合は、Infrastructure Layer で実装し、Domain Layer に注入
- テスト容易性を重視し、モック可能な設計にする

## 4. bulletproof-react（機能別モジュール構成）

### 原則

- 機能別にモジュールを分離
- 各機能は独立したモジュールとして管理
- 機能間の依存関係を最小化

### ディレクトリ構成

```
src/
├── app/                      # Next.js App Router
├── features/                 # 機能別モジュール
│   └── {feature-name}/       # 各機能
│       ├── domain/
│       ├── application/
│       ├── infrastructure/
│       └── presentation/
├── lib/                      # 共通ライブラリ
└── types/                    # 共通型定義
```

## 5. fp-ts による型安全な関数型プログラミング

### 使用する型

- **Either**: 型安全なエラーハンドリング

  ```typescript
  E.Either<AuthValidationError, void>;
  ```

- **Option**: null 安全性の保証

  ```typescript
  O.Option<string>;
  ```

- **TaskEither**: 型安全な非同期処理とエラー処理の統合

  ```typescript
  TE.TaskEither<AuthError, AuthState>;
  ```

- **pipe**: 関数合成とパイプライン処理
  ```typescript
  pipe(
    getAuthState(),
    TE.chainEitherK(validateLevel1Auth),
    TE.chain(() => getOrganizations())
  );
  ```

### 実装方針

- エラーハンドリングは `Either` 型を使用
- null チェックは `Option` 型を使用
- 非同期処理は `TaskEither` 型を使用
- 関数合成は `pipe` を使用して可読性を向上

## 6. 依存性注入（DI）: tsyringe

### 原則

- インターフェースと実装を分離
- 関数型スタイルでの依存性注入
- テスト容易性の向上（モック注入が容易）

### 実装方針

- リポジトリインターフェースは Application Layer で定義
- リポジトリ実装は Infrastructure Layer で実装
- `tsyringe` を使用して依存関係を登録
- 関数型インターフェースを登録可能にする

## 7. 環境変数管理の設計原則

### 原則

- **ユーティリティ経由でのみアクセス**: `process.env` に直接アクセスしない
- **型安全性**: Zod スキーマによる型安全な環境変数の検証
- **DI 可能なスキーマ**: スキーマを外部から注入可能にし、テスト容易性を向上
- **検証**: アプリケーション起動時に環境変数を検証

### 実装方針

- 環境変数は `lib/env/env.ts` から参照
- `process.env` への直接アクセスは ESLint ルールで禁止
- 環境変数の検証は Zod スキーマを使用
- テスト時はカスタムスキーマを注入可能

## 8. 型安全性の重視

### 原則

- TypeScript の型システムを最大限活用
- コンパイル時にエラーを検出
- `fp-ts` による型安全なエラーハンドリング

### 実装方針

- 型定義を明確に記述
- `any` 型の使用を避ける
- 型ガードを適切に使用
- `fp-ts` の型を活用して型安全性を向上

## 実装時の注意事項

### ✅ 推奨される実装

- ドメイン層のロジックは純粋関数として実装
- エラーハンドリングは `Either` 型を使用
- null チェックは `Option` 型を使用
- 非同期処理は `TaskEither` 型を使用
- 環境変数は `lib/env/env.ts` から参照
- 依存関係は `tsyringe` で注入

### ❌ 避けるべき実装

- Domain Layer で外部依存（API、DB）に直接アクセス
- `process.env` への直接アクセス
- `any` 型の使用
- 副作用を含むドメインロジック
- レイヤー間の循環依存

## テスト容易性

### 原則

- 純粋関数による実装により、各層を独立してテスト可能
- DI により、モックの注入が容易
- インターフェースベースの設計により、実装の差し替えが容易

### 実装方針

- ドメイン層のロジックは純粋関数として実装し、単体テストを容易に
- リポジトリインターフェースを定義し、モック実装を注入可能に
- 環境変数スキーマを DI 可能にし、テスト時にカスタムスキーマを注入可能に
