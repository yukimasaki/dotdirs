---
type: command
name: storybook-story-creator
description: プロジェクト独自のルールに従って Storybook のストーリーを作成・維持し、視覚差分の確認を支援するコマンドです。
tools: Read, Edit, Write, Grep, Glob
model: inherit
---

# Storybook Story Creator

**役割**: Storybook のストーリーをプロジェクト規約に沿って作成・更新し、視覚差分の確認やリグレッション検知をしやすくします。

## いつ利用するか

- 新規／既存コンポーネントに props による条件分岐があり、まだ Storybook が整備されていないとき
- Meta 設定やイベントハンドラーの書き方を統一したいとき
- ストーリー名やグループ分けを整理し直したいとき

## 作成ルール

- **条件分岐（`&&` や `? :` など）で表示が変わる箇所のみストーリーを作成する。**
- 単なる props の値違い（variant, size, color 等）だけの差異は、基本ストーリーのみとし追加しない。
- 例: エラー時のメッセージ表示、ローディング中のスピナー表示、データがない際の空表示など
- 非表示状態（`isVisible: false` など）やロジック検証だけを目的としたストーリーは作成しない。
- Meta には `component` だけを最小限セットする。
- イベントハンドラーは各ストーリーの `args` 内で `fn()` を使って渡す。Meta には含めない。
- バレルインポートは禁止。`@/` エイリアスを用いた個別インポートを徹底。
- ストーリー名は日本語で、ひと目で差分が分かるようにする。視覚的に重複するストーリーは避ける。
- TypeScript で実装し、必要に応じて日本語コメントで補足する。

## ワークフロー

1. コンポーネントの props と表示バリエーションを分析
2. 視覚的に意味のある分岐のみ抽出し、必要なストーリーを計画
3. Meta は最小限にしつつ、各ストーリーにわかりやすい名前と `args` を設定
4. イベントハンドラーはすべて `fn()` を使い、ストーリーごとに設定

## 品質チェックリスト

- props が表示へ与える影響を十分にカバーできているか
- 同じ見た目のストーリーが重複していないか
- TypeScript の型や命名規則に沿っているか

## ありがちなアンチパターン

- 内部フックをモックしないと再現できない状態のためだけにストーリーを作る
- 視覚的に同一なのに複数ストーリーを作成する
- ロジック検証や空描画のみを目的としたストーリーを追加する

## コード例

### 基本構成（条件分岐なし）

```typescript
import type { Meta, StoryObj } from "@storybook/react";
import { fn } from "@storybook/test";
import { Button } from "@/components/ui/button/Button";

const meta = {
  component: Button,
} satisfies Meta<typeof Button>;

export default meta;
type Story = StoryObj<typeof meta>;

// props の違いだけの場合は 1 つのストーリーで十分
export const デフォルト: Story = {
  args: {
    onClick: fn(),
    children: "Button",
  },
};
```

### 条件分岐例（エラー状態）

```typescript
import type { Meta, StoryObj } from "@storybook/react";
import { fn } from "@storybook/test";
import { FormField } from "@/components/ui/form-field/FormField";

const meta = {
  component: FormField,
} satisfies Meta<typeof FormField>;

export default meta;
type Story = StoryObj<typeof meta>;

export const 通常表示: Story = {
  args: {
    label: "ユーザー名",
    value: "",
    onChange: fn(),
  },
};

export const エラー表示: Story = {
  args: {
    label: "ユーザー名",
    value: "a",
    error: "ユーザー名は3文字以上で入力してください",
    onChange: fn(),
  },
};
```

### ローディング状態

```typescript
import type { Meta, StoryObj } from "@storybook/react";
import { fn } from "@storybook/test";
import { DataList } from "@/components/features/data/data-list/DataList";

const meta = {
  component: DataList,
} satisfies Meta<typeof DataList>;

export default meta;
type Story = StoryObj<typeof meta>;

const mockData = [
  { id: "1", name: "Item 1" },
  { id: "2", name: "Item 2" },
  { id: "3", name: "Item 3" },
];

export const 通常表示: Story = {
  args: {
    data: mockData,
    onItemClick: fn(),
  },
};

export const ローディング中: Story = {
  args: {
    data: [],
    isLoading: true,
    onItemClick: fn(),
  },
};

export const データなし: Story = {
  args: {
    data: [],
    onItemClick: fn(),
  },
};
```

### 認証状態の切り替え

```typescript
import type { Meta, StoryObj } from "@storybook/react";
import { fn } from "@storybook/test";
import { UserMenu } from "@/components/features/header/user-menu/UserMenu";

const meta = {
  component: UserMenu,
} satisfies Meta<typeof UserMenu>;

export default meta;
type Story = StoryObj<typeof meta>;

const mockUser = {
  id: "1",
  name: "山田 太郎",
  avatarUrl: "https://example.com/avatar.jpg",
};

export const ログイン時: Story = {
  args: {
    user: mockUser,
    onLogout: fn(),
  },
};

export const 未ログイン: Story = {
  args: {
    user: null,
    onLogin: fn(),
  },
};
```

### NG 例

```typescript
// ❌ 単なる props の違いだけで複数ストーリーを作成
export const プライマリ: Story = {
  args: {
    variant: "primary",
    children: "Button",
  },
};

export const セカンダリ: Story = {
  args: {
    variant: "secondary",
    children: "Button",
  },
};

export const ラージ: Story = {
  args: {
    size: "large",
    children: "Button",
  },
};

// ❌ 非表示状態（見た目に違いがない）
export const 非表示: Story = {
  args: {
    isVisible: false,
  },
};

// ❌ 見た目が同じストーリーの重複
export const デフォルト1: Story = {
  args: {
    text: "Test 1",
  },
};

export const デフォルト2: Story = {
  args: {
    text: "Test 2",
  },
};
```

このガイドに従ってストーリーを整備することで、最小の労力で視覚差分を管理し、Storybook をドキュメント／回帰テストの基盤として活用できます。
