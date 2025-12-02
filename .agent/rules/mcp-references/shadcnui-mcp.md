---
alwaysApply: true
type: mcp-reference
name: shadcnui-mcp
tags: ["mcp", "shadcn", "ui-components", "component-library", "design-system"]
---

# shadcn/ui MCP

shadcn/ui CLI によるカタログ参照とコンポーネント導入を補助する MCP です。本プロジェクトでは UI ラッパーを整備する前提として、コンポーネントの仕様や利用例を確認する際に使用します。

## 代表的な機能

### 1. プロジェクト登録済みレジストリの確認

```
mcp__shadcn__get_project_registries
```

- 追加済みレジストリのスラッグを取得し、対象を把握します。

### 2. レジストリ内コンポーネントの一覧取得

```
mcp__shadcn__list_items_in_registries
registries: ['@shadcn']
limit: 20
```

- レジストリ単位で利用可能なアイテムをページング付きで取得します。

### 3. コンポーネント検索

```
mcp__shadcn__search_items_in_registries
registries: ['@shadcn']
query: 'textarea'
limit: 5
```

- 名前や説明に基づいてコンポーネントを検索し、候補を素早く特定します。

### 4. 詳細情報の取得

```
mcp__shadcn__view_items_in_registries
items: ['@shadcn/textarea']
```

- コンポーネントの説明、提供ファイル、利用時の注意点を Markdown として取得します。

### 5. 使用例・デモコードの取得

```
mcp__shadcn__get_item_examples_from_registries
registries: ['@shadcn']
query: 'textarea-demo'
```

- ドキュメントで紹介されるデモ実装を取得し、ラッパーコンポーネントの API 設計参考にします。

### 6. 追加コマンド生成

```
mcp__shadcn__get_add_command_for_items
items: ['@shadcn/textarea', '@shadcn/input']
```

- shadcn CLI の `add` コマンドを自動生成し、導入時のコマンドミスを防ぎます。

### 7. 導入後の確認チェックリスト

```
mcp__shadcn__get_audit_checklist
```

- プロジェクトに追加したコンポーネントが設計指針に従っているかをチェックする項目を取得します。

