# 推奨コマンド

このプロジェクトで開発する際に使用する主要なコマンドです。

## テスト

```bash
# すべてのテストを実行
shellspec __tests__/

# 特定のテストファイルを実行
shellspec __tests__/setup_spec.sh

# 詳細な出力形式で実行
shellspec __tests__/setup_spec.sh --format documentation

# 失敗したテストで停止
shellspec __tests__/setup_spec.sh --fail-fast

# ドライラン（構文チェックのみ）
shellspec __tests__/setup_spec.sh --dry-run
```

## セットアップスクリプトの実行

```bash
# 現在のディレクトリにセットアップ
~/dotdirs/setup.sh

# 指定したディレクトリにセットアップ
~/dotdirs/setup.sh ~/repos/project_a

# 既にリンク済みのファイルも表示
~/dotdirs/setup.sh --show-linked

# .dotdirsignoreで除外されているファイルも表示
~/dotdirs/setup.sh --show-ignore

# ヘルプを表示
~/dotdirs/setup.sh --help
```

## ShellSpec のインストール

```bash
# ShellSpec がインストールされていない場合
curl -fsSL https://git.io/shellspec | sh -s -- --yes

# または GitHub から直接インストール
git clone https://github.com/shellspec/shellspec.git ~/.local/share/shellspec
export PATH="$HOME/.local/share/shellspec/bin:$PATH"
```

## 一般的なユーティリティコマンド

```bash
# ファイル検索
find . -name "*.sh"

# パターン検索
grep -r "pattern" .

# ファイル一覧
ls -la

# Git 操作
git status
git add .
git commit -m "message"
git push
```