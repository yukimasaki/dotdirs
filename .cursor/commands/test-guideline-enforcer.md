---
type: command
name: test-guideline-enforcer
description: Vitest / React Testing Library を用いたテストコードで品質・構造・命名規約を徹底させるコマンドです。
tools: Read, Edit, Write, Grep, Glob
model: inherit
---

# Test Guideline Enforcer

**役割**: Vitest / React Testing Library を使ったテストコードの品質基準・構造・命名を守らせ、DocDD のテストルールに適合させます。

## いつ利用するか

- 新しいテストファイルを作成するとき、または既存テストを大幅に更新するとき
- テストタイトルの日本語表記、AAA パターン、分岐カバレッジなどの規約に準拠しているか確認したいとき
- スナップショットの適用範囲やテストタイプ（ロジック／コンポーネント／スナップショット）を判断したいとき

## 基本ガイドライン

- すべてのテストファイルで `vitest` から必要な関数を明示的にインポートする（グローバル定義に依存しない）。
- `describe` / `test` の説明は日本語で、条件と期待結果を明確に書く。フォーマットは「[条件] のとき、[結果] であること」。
- AAA（Arrange-Act-Assert）パターンを厳守し、`actual` と `expected` を用いた比較を行う。1 テスト 1 アサーション（オブジェクト比較で複数プロパティ検証は可）。
- `describe` のネストは禁止。共有データはトップレベルの `describe` スコープに配置する。
- 全ての分岐・例外ケースを洗い出し、実装詳細ではなく振る舞いを検証してカバレッジを担保する。
- スナップショットはセマンティック HTML やアクセシビリティ属性の確認に限定し、スタイル差分などには使用しない。

## ワークフロー

1. テスト対象の責務と分岐を分析し、ロジック／コンポーネント／スナップショットなどテストタイプを決定
2. 各シナリオのテスト計画を立て、日本語タイトルと期待結果を明記
3. AAA パターンに従って実装し、共有データは `describe` スコープで管理
4. 全テストが規約に従っているか確認し、必要に応じてロジック抽出を提案

## 品質チェックリスト

- Vitest のインポートは漏れなく記述されているか
- すべての条件分岐に対応するテストが存在するか
- AAA パターンと 1 テスト 1 アサーションが守られているか
- `describe` がフラットな構造になっているか

## コード例

### 基本構造

```typescript
import { describe, expect, test } from "vitest";
import { calculateTotal } from "./calculateTotal";

describe("calculateTotal", () => {
  it("商品が1つの場合、その価格を返すこと", () => {
    // Arrange
    const items = [{ price: 100 }];
    const expected = 100;

    // Act
    const actual = calculateTotal(items);

    // Assert
    expect(actual).toBe(expected);
  });

  it("商品が複数の場合、合計金額を返すこと", () => {
    const items = [{ price: 100 }, { price: 200 }, { price: 300 }];
    const expected = 600;
    const actual = calculateTotal(items);
    expect(actual).toBe(expected);
  });

  it("商品が空の場合、0を返すこと", () => {
    const items: Array<{ price: number }> = [];
    const expected = 0;
    const actual = calculateTotal(items);
    expect(actual).toBe(expected);
  });
});
```

### コンポーネントテスト

```typescript
import { render, screen } from "@testing-library/react";
import { describe, expect, test, vi } from "vitest";
import { Button } from "./Button";

describe("Button", () => {
  it("children が表示されること", () => {
    const expected = "クリック";
    render(<Button>{expected}</Button>);
    const actual = screen.getByRole("button", { name: expected });
    expect(actual).toBeInTheDocument();
  });

  it("disabled が true の場合、ボタンが無効化されること", () => {
    render(<Button disabled>クリック</Button>);
    const actual = screen.getByRole("button");
    expect(actual).toBeDisabled();
  });

  it("クリック時に onClick が呼ばれること", async () => {
    const handleClick = vi.fn();
    const { user } = render(<Button onClick={handleClick}>クリック</Button>);
    const button = screen.getByRole("button");

    await user.click(button);

    expect(handleClick).toHaveBeenCalledTimes(1);
  });
});
```

### 共有データ

```typescript
import { describe, expect, test } from "vitest";
import { formatDate } from "./formatDate";

describe("formatDate", () => {
  const testDate = new Date("2024-01-15T10:30:00");

  it("年月日形式でフォーマットされること", () => {
    const format = "YYYY-MM-DD";
    const expected = "2024-01-15";
    const actual = formatDate(testDate, format);
    expect(actual).toBe(expected);
  });

  it("時分秒を含む形式でフォーマットされること", () => {
    const format = "YYYY-MM-DD HH:mm:ss";
    const expected = "2024-01-15 10:30:00";
    const actual = formatDate(testDate, format);
    expect(actual).toBe(expected);
  });
});
```

### エラーケース

```typescript
import { describe, expect, test } from "vitest";
import { divide } from "./divide";

describe("divide", () => {
  it("正常に除算が行われること", () => {
    const a = 10;
    const b = 2;
    const expected = 5;
    const actual = divide(a, b);
    expect(actual).toBe(expected);
  });

  it("0で除算した場合、エラーがスローされること", () => {
    const a = 10;
    const b = 0;
    expect(() => divide(a, b)).toThrow("Division by zero");
  });
});
```

### NG 例と改善例

```typescript
// ❌ describe のネスト
describe("UserService", () => {
  describe("getUser", () => {
    describe("ユーザーが存在する場合", () => {
      it("ユーザーを返すこと", () => {
        // ...
      });
    });
  });
});

// ❌ 複数アサーション（オブジェクト比較を使うべき）
it("ユーザー情報が正しいこと", () => {
  const user = getUser();
  expect(user.name).toBe("Taro");
  expect(user.age).toBe(30);
  expect(user.email).toBe("taro@example.com");
});

// ✅ 正しい書き方
it("ユーザー情報が正しいこと", () => {
  const expected = {
    name: "Taro",
    age: 30,
    email: "taro@example.com",
  };
  const actual = getUser();
  expect(actual).toEqual(expected);
});

// ❌ 実装詳細（内部 state）をテスト

// ✅ 振る舞いをテスト
```

（※内部 state ではなく UI を通じた結果を検証する例を活用）

```typescript
// ❌ AAA を省略
.it("合計金額を計算すること", () => {
  expect(calculateTotal([{ price: 100 }, { price: 200 }])).toBe(300);
});

// ✅ AAA に従う
.it("合計金額を計算すること", () => {
  const items = [{ price: 100 }, { price: 200 }];
  const expected = 300;
  const actual = calculateTotal(items);
  expect(actual).toBe(expected);
});
```

## 追加ガイド

### テストファイルの命名

- `[ComponentName].spec.tsx` または `[functionName].spec.ts`
- テスト対象と同階層の`__tests__`ディレクトリに配置

### インポートの順序

```typescript
import { render, screen } from "@testing-library/react";
import { describe, expect, test, vi } from "vitest";
import { ComponentUnderTest } from "./ComponentUnderTest";
```

### スナップショット

- 利用目的: セマンティック HTML、アクセシビリティ属性、重要な DOM 構造
- 避ける用途: CSS クラス、スタイル差分、振る舞いの代替検証

このガイドラインを守ることで、テストの品質が一定水準に保たれ、将来的なリファクタリングや自動化に耐えうるテストスイートを構築できます。
