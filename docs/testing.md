# テストガイド

このプロジェクトでは、[ShellSpec](https://shellspec.info/) を使用して `setup.sh` のテストを実行しています。

## 前提条件

### ShellSpec のインストール

ShellSpec がインストールされていない場合は、以下のコマンドでインストールできます：

```bash
# curl を使用してインストール
curl -fsSL https://git.io/shellspec | sh -s -- --yes

# または、GitHub から直接インストール
git clone https://github.com/shellspec/shellspec.git ~/.local/share/shellspec
export PATH="$HOME/.local/share/shellspec/bin:$PATH"
```

インストールが完了したら、`shellspec --version` で確認できます。

## テストの実行方法

### 基本的な実行

```bash
# プロジェクトディレクトリに移動
cd ~/dotdirs

# すべてのテストを実行（__tests__ ディレクトリを明示的に指定）
shellspec __tests__/

# 特定のテストファイルを実行
shellspec __tests__/setup_spec.sh
```

**注意**: ShellSpec はデフォルトで `spec/` ディレクトリを探しますが、このプロジェクトでは `__tests__/` ディレクトリを使用しているため、明示的にパスを指定する必要があります。

### 出力形式の選択

```bash
# 詳細な出力形式（各テストケースの説明を表示）
shellspec __tests__/setup_spec.sh --format documentation

# 簡潔な出力形式（デフォルト: progress）
shellspec __tests__/setup_spec.sh --format progress

# タップ形式（CI/CD でよく使用）
shellspec __tests__/setup_spec.sh --format tap
```

### その他の便利なオプション

```bash
# ドライラン（テストを実行せずに構文チェックのみ）
shellspec __tests__/setup_spec.sh --dry-run

# 失敗したテストで停止
shellspec __tests__/setup_spec.sh --fail-fast

# 特定のパターンに一致するテストのみ実行
shellspec __tests__/setup_spec.sh --pattern "ワークフロー1"

# 詳細なログ出力
shellspec __tests__/setup_spec.sh --log-level debug

# カバレッジ情報と共に実行（kcov が必要）
shellspec __tests__/setup_spec.sh --kcov

# 並列実行（複数のテストファイルがある場合）
shellspec __tests__/ --jobs 4
```

## テストファイルの構造

テストファイルは `__tests__/` ディレクトリに配置します。

### ディレクトリ構成

```
~/dotdirs/
├── __tests__/
│   └── setup_spec.sh      # setup.sh のテスト
└── ...
```

### テストファイルの例

```bash
#!/usr/bin/env shellspec

Describe "setup.sh 複雑なワークフローテスト"

  setup_test_environment() {
    # テスト環境のセットアップ
    TEST_DIR=$(mktemp -d)
    # ...
  }

  cleanup_test_environment() {
    # テスト環境のクリーンアップ
    rm -rf "$TEST_DIR"
  }

  BeforeAll 'setup_test_environment'
  AfterAll 'cleanup_test_environment'

  Describe "テストグループ"
    It "テストケースの説明"
      # テストの実行
      When call some_function
      The status should be success
      The output should include "expected text"
    End
  End
End
```

## テスト環境のセットアップ

テストでは、`setup.sh` の関数を読み込むために、環境変数 `SHELLSPEC_TEST=1` を設定しています。これにより、`setup.sh` の `main` 関数が実行されず、関数定義のみが読み込まれます。

```bash
export SHELLSPEC_TEST=1
. "$SHELLSPEC_PROJECT_ROOT/setup.sh"
unset SHELLSPEC_TEST
```

## テストの書き方

### 基本的なアサーション

```bash
# コマンドの実行
When call some_function "arg1" "arg2"

# ステータスコードの確認
The status should be success
The status should be failure

# 出力の確認
The output should include "expected text"
The output should not include "unexpected text"

# ファイルの確認
The file "path/to/file" should be exist
The file "path/to/file" should not be exist
The contents of file "path/to/file" should include "text"
```

### 対話的な入力のモック

`read` コマンドを使用する関数をテストする場合、`Data` を使用して入力をモックできます：

```bash
Data "y"
When call confirm_selection
```

### 環境変数の設定

テスト内で環境変数を設定できます：

```bash
export DOTDIRS_DIR="$TEST_DOTDIRS_DIR"
export CONFIG_DIR="$TEST_CONFIG_DIR"
When call some_function
```

## 現在のテストケース

### ワークフロー 1: 1 回目の実行

`.editorconfig` のみを選択した場合、`.prettierrc` が `.dotdirsignore` に追加されることを確認します。

### ワークフロー 2: 2 回目の実行（--show-ignore オプション付き）

- `.prettierrc` のみが表示され、`.editorconfig` は表示されないことを確認
- `.prettierrc` を選択すると、`.dotdirsignore` から `.prettierrc` が削除されることを確認
- `.prettierrc` を選択しても、`.editorconfig` が `.dotdirsignore` に追加されないことを確認

## トラブルシューティング

### ShellSpec が見つからない

```bash
# パスが通っているか確認
which shellspec

# パスが通っていない場合
export PATH="$HOME/.local/bin:$PATH"
```

### テストが失敗する場合

1. **モジュールの読み込みエラー**: `setup.sh` のモジュール読み込みパスを確認
2. **環境変数の問題**: テスト環境で適切な環境変数が設定されているか確認
3. **ファイルパスの問題**: 相対パスと絶対パスの違いに注意

### デバッグ方法

```bash
# 詳細なログを出力
shellspec __tests__/setup_spec.sh --log-level debug

# 特定のテストのみ実行
shellspec __tests__/setup_spec.sh --pattern "ワークフロー1"
```

## 参考リンク

- [ShellSpec 公式ドキュメント](https://shellspec.info/)
- [ShellSpec GitHub リポジトリ](https://github.com/shellspec/shellspec)
