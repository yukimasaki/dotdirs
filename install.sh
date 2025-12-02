#!/bin/bash

# /**
#  * @file install.sh
#  * @description Reinのインストールと初期化を行うスクリプト。
#  * 必要な機能モジュール（Homebrew, gum, Git, MCP, Rules）を順次実行する。
#  * init.shから呼び出される。
#  */

set -e

# グローバル変数
SCRIPT_DIR=""
INSTALL_DIR=""
FEATURES_DIR=""
REQUIRED_MODULES=(
    "setup_homebrew.sh"
    "setup_gum.sh"
    "setup_git.sh"
    "setup_mcp_json.sh"
    "setup_rules.sh"
)

# /**
#  * @function _init_directories
#  * @description ディレクトリパスを初期化する
#  * @param {string} install_dir_arg - インストールディレクトリの引数
#  */
_init_directories() {
    local install_dir_arg="$1"
    
    # install.shが存在するディレクトリを取得（スクリプトの場所を基準にする）
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    # 第一引数はインストールディレクトリ。指定がない場合はinstall.shが存在するディレクトリをデフォルトとする
    INSTALL_DIR="${install_dir_arg:-$SCRIPT_DIR}"
    
    # 絶対パスを解決する
    INSTALL_DIR=$(cd "$INSTALL_DIR" && pwd)
    
    FEATURES_DIR="${SCRIPT_DIR}/features"
}

# /**
#  * @function _load_modules
#  * @description 必要なモジュールを読み込む
#  * @returns {number} 成功時は0、失敗時は1
#  */
_load_modules() {
    # 必要なモジュールファイルの存在確認
    for module in "${REQUIRED_MODULES[@]}"; do
        if [ ! -f "${FEATURES_DIR}/${module}" ]; then
            echo "Error: Required module ${module} not found"
            return 1
        fi
    done
    
    if [ ! -f "${SCRIPT_DIR}/main.sh" ]; then
        echo "Error: main.sh not found"
        return 1
    fi
    
    # 機能モジュールを読み込む
    for module in "${REQUIRED_MODULES[@]}"; do
        source "${FEATURES_DIR}/${module}"
    done
    
    return 0
}

# /**
#  * @function _run_setup
#  * @description 各セットアップ関数を順次実行する
#  * @returns {number} 成功時は0、失敗時は1
#  */
_run_setup() {
    # 1. Homebrewのセットアップ
    if ! setup_homebrew; then
        echo "Failed to setup Homebrew. Exiting."
        return 1
    fi
    
    # 2. gumのセットアップ
    if ! setup_gum; then
        echo "Failed to setup gum. Exiting."
        return 1
    fi
    
    # 3. Gitリポジトリ同期
    if ! setup_git "$INSTALL_DIR"; then
        echo "Failed to setup git repository. Exiting."
        return 1
    fi
    
    # 4. MCP設定ファイルのセットアップ
    if ! setup_mcp_json "$INSTALL_DIR" "$SCRIPT_DIR"; then
        echo "Failed to setup MCP configuration. Exiting."
        return 1
    fi
    
    # 5. ルールファイルのセットアップ
    if ! setup_rules "$INSTALL_DIR" "$SCRIPT_DIR"; then
        echo "Failed to setup rules. Exiting."
        return 1
    fi
    
    return 0
}

# /**
#  * @function _show_completion_message
#  * @description 完了メッセージを表示する
#  */
_show_completion_message() {
    if command -v gum &> /dev/null; then
        gum style \
            --foreground 82 --border-foreground 82 --border rounded \
            --align center --width 50 --margin "1 2" --padding "2 4" \
            "Installation Complete!" \
            "Please restart your shell."
    else
        echo "Installation Complete!"
        echo "Please restart your shell."
    fi
}

# /**
#  * @function main
#  * @description メイン処理
#  * @param {string} install_dir_arg - インストールディレクトリの引数
#  * @returns {number} 成功時は0、失敗時は1
#  */
main() {
    local install_dir_arg="$1"
    
    echo "Starting Rein setup..."
    
    # ディレクトリの初期化
    _init_directories "$install_dir_arg"
    
    # モジュールの読み込み
    if ! _load_modules; then
        exit 1
    fi
    
    # セットアップの実行
    if ! _run_setup; then
        exit 1
    fi
    
    # 完了メッセージの表示
    _show_completion_message
    
    return 0
}

# メイン処理の実行
main "$@"

