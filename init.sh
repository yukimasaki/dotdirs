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
#  */
_init_directories() {
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
}

# /**
#  * @function _clone_repository
#  * @description リポジトリをgit cloneで取得する
#  * @returns {number} 成功時は0、失敗時は1
#  */
_clone_repository() {
    # 通常実行時（ローカルにファイルがある場合）はスキップ
    if [[ "${BASH_SOURCE[0]}" != *"/dev/fd/"* ]] && [[ "${BASH_SOURCE[0]}" != "-" ]]; then
        # ローカルファイルが存在する場合はそれを使用
        if [ -f "${SCRIPT_DIR}/install.sh" ]; then
            return 0
        fi
    fi
    
    # gitコマンドの確認
    if ! command -v git &> /dev/null; then
        echo "Error: git is required but not found."
        echo "Please install git first."
        return 1
    fi
    
    # SCRIPT_DIRが空でない場合、git cloneは失敗するため確認
    if [ "$(ls -A "$SCRIPT_DIR" 2>/dev/null)" ]; then
        echo "Error: SCRIPT_DIR is not empty. Cannot clone repository."
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
