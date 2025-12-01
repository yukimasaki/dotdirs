#!/bin/bash

# /**
#  * @file init.sh
#  * @description Reinのインストールと初期化を行うエントリーポイントスクリプト。
#  * 必要な機能モジュール（Homebrew, gum, Shell Setup, Git, MCP）を順次実行する。
#  * 
#  * 使用方法:
#  *   curl -fsSL https://raw.githubusercontent.com/yukimasaki/dotdirs/main/init.sh | bash -s -- .
#  */

set -e

# グローバル変数
GITHUB_REPO=""
GITHUB_BRANCH=""
GITHUB_BASE_URL=""
SCRIPT_DIR=""
INSTALL_DIR=""
FEATURES_DIR=""
REQUIRED_MODULES=(
    "setup_homebrew.sh"
    "setup_gum.sh"
    "setup_git.sh"
    "setup_shell.sh"
    "setup_mcp_json.sh"
)

# /**
#  * @function _init_config
#  * @description 設定変数を初期化する
#  */
_init_config() {
    GITHUB_REPO="${GITHUB_REPO:-yukimasaki/dotdirs}"
    GITHUB_BRANCH="${GITHUB_BRANCH:-main}"
    GITHUB_BASE_URL="https://raw.githubusercontent.com/${GITHUB_REPO}/${GITHUB_BRANCH}"
}

# /**
#  * @function _init_directories
#  * @description ディレクトリパスを初期化する
#  * @param {string} install_dir_arg - インストールディレクトリの引数
#  */
_init_directories() {
    local install_dir_arg="$1"
    
    # init.shが存在するディレクトリを取得（スクリプトの場所を基準にする）
    # パイプ経由で実行される場合は、一時ディレクトリを使用
    if [[ "${BASH_SOURCE[0]}" == *"/dev/fd/"* ]] || [[ "${BASH_SOURCE[0]}" == "-" ]]; then
        # パイプ経由で実行されている場合
        SCRIPT_DIR="${TMPDIR:-/tmp}/rein-setup-$$"
        mkdir -p "$SCRIPT_DIR"
        trap "rm -rf '$SCRIPT_DIR'" EXIT
    else
        # 通常の実行
        SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    fi
    
    # 第一引数はインストールディレクトリ。指定がない場合はinit.shが存在するディレクトリをデフォルトとする
    INSTALL_DIR="${install_dir_arg:-$SCRIPT_DIR}"
    
    # 絶対パスを解決する
    INSTALL_DIR=$(cd "$INSTALL_DIR" && pwd)
    
    FEATURES_DIR="${SCRIPT_DIR}/features"
}

# /**
#  * @function _download_module
#  * @description 機能モジュールをダウンロードする
#  * @param {string} module_name - モジュール名（例: setup_homebrew.sh）
#  * @returns {number} 成功時は0、失敗時は1
#  */
_download_module() {
    local module_name="$1"
    local module_url="${GITHUB_BASE_URL}/features/${module_name}"
    local module_path="${FEATURES_DIR}/${module_name}"
    
    # featuresディレクトリが存在しない場合は作成
    mkdir -p "$FEATURES_DIR"
    
    # モジュールをダウンロード
    if curl -fsSL "$module_url" -o "$module_path" 2>/dev/null; then
        chmod +x "$module_path"
        return 0
    else
        echo "Warning: Failed to download ${module_name}. Trying to use local file if exists."
        # ローカルファイルが存在する場合はそれを使用
        if [ -f "${INSTALL_DIR}/features/${module_name}" ]; then
            cp "${INSTALL_DIR}/features/${module_name}" "$module_path"
            chmod +x "$module_path"
            return 0
        fi
        return 1
    fi
}

# /**
#  * @function _load_modules
#  * @description 必要なモジュールをダウンロードして読み込む
#  * @returns {number} 成功時は0、失敗時は1
#  */
_load_modules() {
    # ローカルのfeaturesディレクトリが存在しない場合、または必要なファイルがない場合はダウンロード
    for module in "${REQUIRED_MODULES[@]}"; do
        if [ ! -f "${FEATURES_DIR}/${module}" ]; then
            echo "Downloading ${module}..."
            if ! _download_module "$module"; then
                echo "Error: Failed to download or find ${module}"
                return 1
            fi
        fi
    done
    
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
    
    # 3. シェルのセットアップ
    if ! setup_shell "$INSTALL_DIR"; then
        echo "Failed to setup shell. Exiting."
        return 1
    fi
    
    # 4. Gitリポジトリ同期
    if ! setup_git "$INSTALL_DIR"; then
        echo "Failed to setup git repository. Exiting."
        return 1
    fi
    
    # 5. MCP設定ファイルのセットアップ
    if ! setup_mcp_json "$INSTALL_DIR"; then
        echo "Failed to setup MCP configuration. Exiting."
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
    
    # 設定の初期化
    _init_config
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
