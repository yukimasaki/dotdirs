---
alwaysApply: true
type: mcp-reference
name: browser-eval-mcp
tags: ["mcp", "browser-eval", "playwright", "automation", "testing"]
---

# Browser Eval MCP

Playwright を使用したブラウザ自動化のための MCP です。

**注意**: Chrome DevTools MCP が利用できる場合はそちらを優先してください。Browser Eval MCP はより高度な自動化やテストシナリオに使用します。

## ブラウザ起動

```
mcp__next-devtools__browser_eval
action: 'start'
browser: 'chrome'  # 'chrome', 'firefox', 'webkit'
headless: false    # UIを表示する場合はfalse
```

**説明**: ブラウザを起動します。verbose ログは常に有効です。

## ページ移動

```
mcp__next-devtools__browser_eval
action: 'navigate'
url: 'http://localhost:3000'
```

**説明**: 指定した URL に移動します。

## スクリーンショット

```
mcp__next-devtools__browser_eval
action: 'screenshot'
fullPage: true
```

**説明**: ページのスクリーンショットを取得します。

## コンソールメッセージ取得

```
mcp__next-devtools__browser_eval
action: 'console_messages'
errorsOnly: true  # エラーのみ取得
```

**説明**: ブラウザコンソールのメッセージを取得します。

**重要**: Next.js プロジェクトの場合、`nextjs_runtime` MCP を優先してください。こちらはより詳細な情報を提供します。

## その他のアクション

- `click`: 要素をクリック
- `type`: テキスト入力
- `fill_form`: フォーム一括入力
- `evaluate`: JavaScript を実行
- `drag`: ドラッグ&ドロップ
- `upload_file`: ファイルアップロード
- `list_tools`: 利用可能なツール一覧

詳細は `action: 'list_tools'` で確認してください。

## ブラウザクローズ

```
mcp__next-devtools__browser_eval
action: 'close'
```

**説明**: ブラウザを閉じます。

