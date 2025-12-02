---
alwaysApply: true
type: mcp-reference
name: nextjs-runtime-mcp
tags: ["mcp", "nextjs", "runtime", "error-checking", "verification"]
---

# Next.js Runtime MCP

Next.js 開発サーバーのランタイム情報を取得するための MCP です。

## サーバー検出とツール一覧

### サーバー検出

```
mcp__next-devtools__nextjs_runtime
action: 'discover_servers'
```

**説明**: 実行中の Next.js 開発サーバーを自動検出します。

### 利用可能なツールを確認

```
mcp__next-devtools__nextjs_runtime
action: 'list_tools'
port: <検出したポート番号>
```

**説明**: Next.js MCP が提供するすべてのツールとそのスキーマを取得します。

## ランタイムエラー・警告の確認

### ビルドエラー・ランタイムエラーを取得

```
mcp__next-devtools__nextjs_runtime
action: 'call_tool'
port: <ポート番号>
toolName: 'get-errors'
```

**説明**: 現在のビルドエラーやランタイムエラーを取得します。

**使用タイミング**: 08_quality-checks で必須。エラーがゼロであることを確認します。

### ログを取得

```
mcp__next-devtools__nextjs_runtime
action: 'call_tool'
port: <ポート番号>
toolName: 'get-logs'
```

**説明**: Next.js 開発サーバーのログを取得します。

### 診断情報を取得

```
mcp__next-devtools__nextjs_runtime
action: 'call_tool'
port: <ポート番号>
toolName: 'get-diagnostics'
```

**説明**: システムの診断情報（メモリ使用量、CPU 使用率など）を取得します。

## ルート情報の取得

### アプリケーションのルート構造を取得

```
mcp__next-devtools__nextjs_runtime
action: 'call_tool'
port: <ポート番号>
toolName: 'get-routes'
```

**説明**: アプリケーション内のすべてのルート（App Router）を一覧表示します。

**使用タイミング**: 08_quality-checks で推奨。すべてのルートが正しく認識されているか確認します。

### 特定ルートの詳細情報を取得

```
mcp__next-devtools__nextjs_runtime
action: 'call_tool'
port: <ポート番号>
toolName: 'get-route-info'
args: {path: '/your-route'}
```

**説明**: 特定のルートに関する詳細情報（コンポーネント、レンダリング戦略など）を取得します。

**注意**: `args`パラメータは必ずオブジェクトとして渡す必要があります。

## キャッシュ・ビルド状態の確認

### キャッシュ情報を取得

```
mcp__next-devtools__nextjs_runtime
action: 'call_tool'
port: <ポート番号>
toolName: 'get-cache-info'
```

**説明**: Next.js のキャッシュ状態を取得します。

### キャッシュをクリア

```
mcp__next-devtools__nextjs_runtime
action: 'call_tool'
port: <ポート番号>
toolName: 'clear-cache'
```

**説明**: Next.js のキャッシュをクリアします。

**使用タイミング**: 古いキャッシュが原因で問題が発生している場合。

