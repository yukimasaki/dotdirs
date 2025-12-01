#!/bin/bash

# /**
#  * @file init.sh
#  * @description Reinのインストールと初期化を行うエントリーポイントスクリプト。
#  * 必要な機能モジュール（Homebrew, gum, Shell Setup, Git, MCP）を順次実行する。
#  */

set -e

# init.shが存在するディレクトリを取得（スクリプトの場所を基準にする）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 第一引数はインストールディレクトリ。指定がない場合はinit.shが存在するディレクトリをデフォルトとする
INSTALL_DIR="${1:-$SCRIPT_DIR}"

# 絶対パスを解決する
INSTALL_DIR=$(cd "$INSTALL_DIR" && pwd)

echo "Starting Rein setup..."

# 機能モジュールを読み込む
source "${INSTALL_DIR}/features/setup_homebrew.sh"
source "${INSTALL_DIR}/features/setup_gum.sh"
source "${INSTALL_DIR}/features/setup_git.sh"
source "${INSTALL_DIR}/features/setup_shell.sh"
source "${INSTALL_DIR}/features/setup_mcp_json.sh"

# 1. Homebrewのセットアップ
if ! setup_homebrew; then
    echo "Failed to setup Homebrew. Exiting."
    exit 1
fi

# 2. gumのセットアップ
if ! setup_gum; then
    echo "Failed to setup gum. Exiting."
    exit 1
fi

# 3. シェルのセットアップ
if ! setup_shell "$INSTALL_DIR"; then
    echo "Failed to setup shell. Exiting."
    exit 1
fi

# 4. Gitリポジトリ同期
if ! setup_git "$INSTALL_DIR"; then
    echo "Failed to setup git repository. Exiting."
    exit 1
fi

# 5. MCP設定ファイルのセットアップ
if ! setup_mcp_json "$INSTALL_DIR"; then
    echo "Failed to setup MCP configuration. Exiting."
    exit 1
fi

gum style \
    --foreground 82 --border-foreground 82 --border rounded \
    --align center --width 50 --margin "1 2" --padding "2 4" \
    "Installation Complete!" \
    "Please restart your shell."
