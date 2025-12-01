#!/bin/bash

# /**
#  * @file init.sh
#  * @description Reinのインストールスクリプトのエントリーポイント。
#  * GitHubからリポジトリをクローンし、install.shを実行する。
#  * 
#  * 使用方法:
#  *   curl -fsSL https://raw.githubusercontent.com/yukimasaki/dotdirs/main/init.sh | bash -s -- .
#  */

set -e

# グローバル変数
GITHUB_REPO=""
GITHUB_BRANCH=""
SCRIPT_DIR=""

# /**
#  * @function _init_config
#  * @description 設定変数を初期化する
#  */
_init_config() {
    GITHUB_REPO="${GITHUB_REPO:-yukimasaki/dotdirs}"
    GITHUB_BRANCH="${GITHUB_BRANCH:-main}"
}

# /**
#  * @function _init_directories
#  * @description ディレクトリパスを初期化する
#  * 常に/tmp以下の一時ディレクトリを使用する
#  */
_init_directories() {
    # 常に一時ディレクトリを使用
    SCRIPT_DIR="${TMPDIR:-/tmp}/rein-setup-$$"
    # 既に存在する場合は削除してから作成
    if [ -d "$SCRIPT_DIR" ]; then
        rm -rf "$SCRIPT_DIR"
    fi
    mkdir -p "$SCRIPT_DIR"
    trap "rm -rf '$SCRIPT_DIR'" EXIT
}

# /**
#  * @function _clone_repository
#  * @description リポジトリをgit cloneで取得する
#  * @returns {number} 成功時は0、失敗時は1
#  */
_clone_repository() {
    # gitコマンドの確認
    if ! command -v git &> /dev/null; then
        echo "Error: git is required but not found."
        echo "Please install git first."
        return 1
    fi
    
    local repo_url="https://github.com/${GITHUB_REPO}.git"
    
    echo "Cloning repository from GitHub..."
    
    # SCRIPT_DIRに直接クローン（cpコマンドは不要）
    if git clone --branch "$GITHUB_BRANCH" "$repo_url" "$SCRIPT_DIR" 2>/dev/null; then
        # 実行権限を付与
        if [ -f "${SCRIPT_DIR}/main.sh" ]; then
            chmod +x "${SCRIPT_DIR}/main.sh"
        fi
        
        if [ -f "${SCRIPT_DIR}/install.sh" ]; then
            chmod +x "${SCRIPT_DIR}/install.sh"
        fi
        
        return 0
    else
        echo "Error: Failed to clone repository."
        return 1
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
    
    # 設定の初期化
    _init_config
    _init_directories
    
    # リポジトリのクローン
    if ! _clone_repository; then
        echo "Error: Failed to clone repository."
        exit 1
    fi
    
    # install.shの存在確認
    if [ ! -f "${SCRIPT_DIR}/install.sh" ]; then
        echo "Error: install.sh not found after cloning."
        exit 1
    fi
    
    # install.shを実行（作業ディレクトリを引数として渡す）
    "${SCRIPT_DIR}/install.sh" "$install_dir_arg"
}

# メイン処理の実行
main "$@"
