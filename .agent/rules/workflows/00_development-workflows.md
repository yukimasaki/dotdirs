---
alwaysApply: true
type: rule
name: 00_development-workflows
tags: ["workflow", "development"]
---

# Development Workflow Rules

このファイルは、AIエージェントを使用した開発ワークフローの標準手順を定義します。
新機能の追加やバグ修正を行う際は、以下のフローに従ってください。

## 概要

このワークフローは、開発作業を複数のフェーズに分割し、各フェーズで適切なツールとエージェントを使用して品質の高いコードを効率的に作成することを目的としています。

各フェーズは独立したルールファイルとして細分化されており、詳細な手順は各フェーズのルールファイルを参照してください。

## 基本方針

- **できるだけ全てのフェーズを実行する**（タイプ別の推奨フローは下記参照）
- **各フェーズで TodoWrite ツールを活用**して進捗を管理する
- **不明点があれば AskUserQuestion で確認**してから進める
- **エラーが発生したら必ず修正**してから次のフェーズに進む
- **コミット前にすべてのチェックがパス**していることを確認
- **段階的にコミット**し、大きすぎる変更を避ける
- **Next.js MCP、Chrome DevTools MCPを積極的に活用**して動作確認を徹底する

---

## 各フェーズへの参照

| Phase | フェーズ名 | ルールファイル | 必須/推奨 | 説明 |
|-------|-----------|---------------|----------|------|
| **01_investigation-research** | Investigation & Research | [01_investigation-research.md](./01_investigation-research.md) | **必須** | 既存コードベースの調査、ADR確認、ライブラリドキュメント確認 |
| **02_architecture-design** | Architecture Design | [02_architecture-design.md](./02_architecture-design.md) | 推奨 | 新機能や大規模変更時のアーキテクチャ設計 |
| **03_ui-ux-design** | UI/UX Design | [03_ui-ux-design.md](./03_ui-ux-design.md) | 推奨 | UI変更がある場合のデザインレビューと改善提案 |
| **04_planning** | Planning | [04_planning.md](./04_planning.md) | **必須** | TodoWriteツールを使用した実装計画の立案 |
| **05_impementation** | Implementation | [05_impementation.md](./05_impementation.md) | **必須** | Serena MCPを使用したシンボルベースのコード実装 |
| **06_testing** | Testing & Stories | [06_testing.md](./06_testing.md) | 推奨 | ロジック変更がある場合のテストコードとStorybookストーリー作成 |
| **07_code-review** | Code Review | [07_code-review.md](./07_code-review.md) | 推奨 | リファクタリングが必要な場合のコードレビュー |
| **08_quality-checks** | Quality Checks | [08_quality-checks.md](./08_quality-checks.md) | **必須** | 型チェック、Lint、テスト実行による品質確認 |
| **09_change-log** | Change Log | [09_change-log.md](./09_change-log.md) | **必須** | コード変更完了後のチェンジログ作成 |

---

## 各フェーズの使用タイミング

| Phase | フェーズ名 | いつ使うか | スキップできるケース |
|-------|-----------|-----------|---------------------|
| **01_investigation-research** | Investigation & Research | **常に最初に実行** | なし（必須） |
| **02_architecture-design** | Architecture Design | 新機能追加、大規模変更、新しいパターンの導入 | 既存パターンに完全に倣う場合、1ファイル以内の小さな修正、ドキュメントやスタイルのみの変更 |
| **03_ui-ux-design** | UI/UX Design | 新規コンポーネント作成、既存コンポーネントのUI変更、スタイル調整 | UIに変更がない場合（ロジックのみの変更、バックエンド処理のみの変更） |
| **04_planning** | Planning | **01_investigation-research完了後、実装前に必ず実行** | なし（必須） |
| **05_impementation** | Implementation | **04_planning完了後、必ず実行** | なし（必須） |
| **06_testing** | Testing & Stories | ロジック変更、新規コンポーネント作成、条件分岐の追加 | UI/表示のみの変更でロジック変更なし、既存テストが十分にカバーしている場合、ドキュメントのみの変更 |
| **07_code-review** | Code Review | コードの品質に不安がある場合、リファクタリングが必要な場合、複雑なロジックを実装した場合 | シンプルな変更で品質に問題がない場合 |
| **08_quality-checks** | Quality Checks | **実装完了後、必ず実行** | なし（必須） |
| **09_change-log** | Change Log | **コード変更完了後、必ず実行** | なし（必須） |

---

## 変更タイプ別の推奨フロー

変更のタイプに応じて、適切なフローを選択してください：

| 変更タイプ | 推奨フロー | 所要時間目安 | 説明 |
|-----------|-----------|-------------|------|
| **新機能追加** | 01_investigation-research から 09_change-log まで全て | 60-120分 | 完全なワークフロー（02_architecture-design, 03_ui-ux-design, 06_testing, 07_code-reviewを含む） |
| **中規模バグ修正** | 01_investigation-research, 04_planning, 05_impementation, 06_testing, 08_quality-checks, 09_change-log | 30-60分 | 調査→実装→テスト→確認 |
| **UI/デザイン調整** | 01_investigation-research, 03_ui-ux-design, 04_planning, 05_impementation, 08_quality-checks, 09_change-log | 20-40分 | UIデザインレビュー含む |
| **小規模リファクタ** | 01_investigation-research, 04_planning, 05_impementation, 07_code-review, 08_quality-checks, 09_change-log | 15-30分 | 既存パターン踏襲、コードレビュー含む |
| **タイポ修正** | 05_impementation, 08_quality-checks, 09_change-log | 5分 | 設定ファイルや小さな修正 |
| **ドキュメント更新** | 05_impementation, 08_quality-checks, 09_change-log | 5-10分 | ドキュメントのみの変更 |

**注意**: 01_investigation-research（Investigation & Research）は常に最初に実行してください。ADR確認は必須です。

---

## フェーズ間の依存関係

以下の順序でフェーズを実行してください：

```
01_investigation-research (Investigation & Research)
    ↓
02_architecture-design (Architecture Design) [新機能/大規模変更時のみ]
    ↓
03_ui-ux-design (UI/UX Design) [UI変更がある場合のみ]
    ↓
04_planning (Planning)
    ↓
05_impementation (Implementation)
    ↓
06_testing (Testing & Stories) [ロジック変更がある場合のみ]
    ↓
07_code-review (Code Review) [リファクタリングが必要な場合のみ]
    ↓
08_quality-checks (Quality Checks)
    ↓
09_change-log (Change Log)
```

**重要な依存関係:**

- **04_planningの前に**: 01_investigation-researchのADR確認が完了していること（必須）、UI変更がある場合は03_ui-ux-designが完了し承認を得ていること
- **05_impementationの前に**: 01_investigation-researchのADR確認が完了していること（必須）、UI変更がある場合は03_ui-ux-designで承認された改善案に従うこと
- **06_testingの前に**: 05_impementationが完了していること
- **07_code-reviewの前に**: 05_impementationが完了していること
- **08_quality-checksの前に**: 05_impementationが完了していること（06_testing, 07_code-reviewは任意）
- **09_change-logの前に**: 08_quality-checksが完了していること

---

## 使用エージェント/コマンド

### エージェントのファイルパス

**⚠️ 重要: エージェントファイルの探索方法**

エージェント（コマンド）ファイルは、プロジェクトのルートディレクトリから再帰的に探索してください。固定パスに依存せず、以下の手順で見つけ出してください：

1. **プロジェクトルートの特定**
   - ワークスペースのルートディレクトリを特定する
   - `.git`ディレクトリや`package.json`などのプロジェクトルートマーカーを確認

2. **フロントマターの探索**
   - プロジェクトルートから再帰的に`.md`ファイルを探索する
   - 各`.md`ファイルのフロントマター（YAML形式のメタデータ）を確認
   - フロントマターに`type: command`が含まれているファイルを特定する

3. **探索コマンドの例**
   ```bash
   # プロジェクトルートから再帰的に探索
   find . -name "*.md" -type f | while read file; do
     if grep -q "^type: command" "$file" || grep -q "type:\s*command" "$file"; then
       echo "$file"
     fi
   done
   ```

4. **探索ツールの使用**
   - `glob_file_search`ツールで`**/*.md`パターンで全Markdownファイルを検索
   - 各ファイルを読み込み、フロントマターに`type: command`が含まれているか確認
   - `grep`ツールで`type:\s*command`パターンを検索

5. **エージェント名の特定**
   - 見つかったファイルのフロントマターから`name`や`title`フィールドを確認
   - ファイル名からもエージェント名を推測可能（例: `component-refactoring-specialist.md`）

**注意事項:**
- ファイルパスはプロジェクトによって異なる可能性があるため、固定パスに依存しない
- 複数のディレクトリにエージェントファイルが配置されている可能性を考慮する
- サブディレクトリ（`node_modules`、`.git`など）は探索対象から除外することを推奨

### 利用可能なエージェント

- **`component-refactoring-specialist`** - Reactコンポーネントのリファクタリング専門家。ロジック抽出、プレゼンターパターン適用、ディレクトリ構造の再編成を担当
- **`test-guideline-enforcer`** - Vitest / React Testing Libraryを使用したテストコードの品質、構造、命名規約を強制
- **`storybook-story-creator`** - プロジェクトルールに準拠したStorybookストーリーの作成とメンテナンス
- **`ui-design-advisor`** - ダークテーマに焦点を当てたUI/UXデザイン専門家。レイアウトのレビューと改善提案を担当
- **`spec-document-creator`** - 拡張可能な仕様書作成コマンド。機能仕様、API仕様、アーキテクチャ仕様など複数のドキュメントタイプをサポート
- **`adr-memory-manager`** - AI用のADR（Architecture Decision Record）を自動記録・検索・管理。JSON形式で機械可読性を最優先に設計
- **`project-onboarding`** ロジェクトの構造、ドメイン知識、技術スタック、アーキテクチャパターンを分析・記録。新規プロジェクトのオンボーディングに最適
- **`commit-message`** onventional Commits準拠の日本語コミットメッセージを生成。変更内容を分析して適切なコミットメッセージを作成
- **`quality-check`** チェック、テスト、リントチェックの結果を簡潔に報告。自動修正は行わず、現状の品質を確認
- **`tdd-todo-creator`** - TDD原則に従った実装TODOリストを作成。テスト→実装→リファクタリング→品質チェックのサイクルをフェーズごとに再帰的に実行可能にする

---

## MCPリファレンス

### MCPリファレンスファイルの探索方法

**⚠️ 重要: MCPリファレンスファイルの探索方法**

MCPリファレンスファイルは、プロジェクトのルートディレクトリから再帰的に探索してください。固定パスに依存せず、以下の手順で見つけ出してください：

1. **プロジェクトルートの特定**
   - ワークスペースのルートディレクトリを特定する
   - `.git`ディレクトリや`package.json`などのプロジェクトルートマーカーを確認

2. **フロントマターの探索**
   - プロジェクトルートから再帰的に`.md`ファイルを探索する
   - 各`.md`ファイルのフロントマター（YAML形式のメタデータ）を確認
   - フロントマターに`type: mcp-reference`が含まれているファイルを特定する

3. **探索コマンドの例**
   ```bash
   # プロジェクトルートから再帰的に探索
   find . -name "*.md" -type f | while read file; do
     if grep -q "^type: mcp-reference" "$file" || grep -q "type:\s*mcp-reference" "$file"; then
       echo "$file"
     fi
   done
   ```

4. **探索ツールの使用**
   - `glob_file_search`ツールで`**/*.md`パターンで全Markdownファイルを検索
   - 各ファイルを読み込み、フロントマターに`type: mcp-reference`が含まれているか確認
   - `grep`ツールで`type:\s*mcp-reference`パターンを検索

5. **MCPリファレンス名の特定**
   - 見つかったファイルのフロントマターから`name`フィールドを確認
   - ファイル名からもMCP名を推測可能（例: `kiri-mcp.md`）

**注意事項:**
- ファイルパスはプロジェクトによって異なる可能性があるため、固定パスに依存しない
- 複数のディレクトリにMCPリファレンスファイルが配置されている可能性を考慮する
- サブディレクトリ（`node_modules`、`.git`など）は探索対象から除外することを推奨

### 利用可能なMCPリファレンス

MCPリファレンスファイルには、各MCPツールの詳細なコマンドとパラメータが記載されています。各フェーズで使用するMCPツールの詳細を確認する際に参照してください。

**主なMCPリファレンス:**
- **Kiri MCP** (`kiri-mcp`) - コードベース検索とコンテキスト抽出
- **Serena MCP** (`serena-mcp`) - シンボルベースのコード編集
- **Next.js Runtime MCP** (`nextjs-runtime-mcp`) - Next.js開発サーバーのランタイム情報
- **Next.js Documentation MCP** (`nextjs-documentation-mcp`) - Next.jsドキュメント検索
- **Chrome DevTools MCP** (`chrome-devtools-mcp`) - ブラウザの詳細な動作確認とテスト
- **Browser Eval MCP** (`browser-eval-mcp`) - Playwrightを使用したブラウザ自動化
- **shadcn/ui MCP** (`shadcnui-mcp`) - shadcn/uiコンポーネントカタログ参照

**使用タイミング:**
- 各フェーズでMCPツールを使用する際、詳細なコマンドやパラメータが必要な場合は、対応するMCPリファレンスファイルを参照してください
- 特に`01_investigation-research`、`05_impementation`、`08_quality-checks`フェーズでMCPツールを積極的に使用します

---

## MCPツールの使い分け

| フェーズ | 使用MCP | 主な用途 |
|---------|---------|---------|
| **01_investigation-research: 調査** | Kiri MCP | コードベース検索、コンテキスト抽出、依存関係分析 |
| **01_investigation-research: 調査** | Context7 MCP | ライブラリドキュメント取得 |
| **05_impementation: 実装** | Serena MCP | シンボルベース編集、リネーム、挿入・置換 |
| **08_quality-checks: 品質チェック** | IDE Diagnostics | 型エラー、Lintエラーの詳細確認 |

**Kiri vs Serenaの使い分け**:
- **調査（読み取り）**: Kiri → セマンティック検索、自動ランク付け、依存関係分析
- **実装（書き込み）**: Serena → シンボル編集、リネーム、挿入・置換