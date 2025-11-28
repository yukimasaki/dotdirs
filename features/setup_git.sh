#!/bin/bash

# /**
#  * @file setup_git.sh
#  * @description dotfilesリポジトリを同期する。
#  * プロトコル選択、URL入力、接続テスト、ブランチ選択、クローンを実行する。
#  */

setup_git() {
    local install_dir="$1"
    local storage_dir="${install_dir}/storage"

    # dotfilesリポジトリの有無を確認
    if ! gum confirm "$(gettext "Do you have a dotfiles repository to sync?")"; then
        echo "$(gettext "Skipping repository sync.")"
        return 0
    fi

    # プロトコル選択
    echo "$(gettext "Select protocol:")"
    local protocol=$(gum choose "SSH" "HTTPS")

    # リモートURL入力
    local remote_url=""
    case "$protocol" in
        "HTTPS")
            echo "$(gettext "Enter repository URL (e.g., https://github.com/user/repo.git):")"
            remote_url=$(gum input --placeholder "https://github.com/user/repo.git")
            ;;
        "SSH")
            echo "$(gettext "Enter repository URL (e.g., git@github.com:user/repo.git or gh-alias:user/repo.git):")"
            remote_url=$(gum input --placeholder "git@github.com:user/repo.git")
            ;;
    esac

    if [ -z "$remote_url" ]; then
        echo "$(gettext "Error: Repository URL is required.")"
        return 1
    fi

    # 接続テスト
    echo "$(gettext "Testing connection to repository...")"
    if ! git ls-remote "$remote_url" &> /dev/null; then
        echo "$(gettext "Error: Failed to connect to repository.")"
        echo "$(gettext "Please check the URL and your network connection.")"
        return 1
    fi

    echo "$(gettext "Connection successful!")"

    # ブランチ一覧取得
    echo "$(gettext "Fetching branches...")"
    local branches=$(git ls-remote --heads "$remote_url" | sed 's|.*refs/heads/||' | sort)
    
    if [ -z "$branches" ]; then
        echo "$(gettext "Error: No branches found in repository.")"
        return 1
    fi

    # ブランチ選択
    echo "$(gettext "Select branch to clone:")"
    local selected_branch=$(echo "$branches" | gum choose)

    if [ -z "$selected_branch" ]; then
        echo "$(gettext "Error: Branch selection is required.")"
        return 1
    fi

    # storage ディレクトリが既に存在する場合の処理
    if [ -d "$storage_dir" ] && [ "$(ls -A "$storage_dir")" ]; then
        echo "$(gettext "Warning: storage directory is not empty.")"
        if ! gum confirm "$(gettext "Do you want to remove existing contents and clone?")"; then
            echo "$(gettext "Clone cancelled.")"
            return 0
        fi
        rm -rf "${storage_dir:?}"/*
        rm -rf "${storage_dir:?}"/.[!.]*
    fi

    # storage ディレクトリが存在しない場合は作成
    if [ ! -d "$storage_dir" ]; then
        mkdir -p "$storage_dir"
    fi

    # クローン実行
    echo "$(gettext "Cloning repository...")"
    if git clone --branch "$selected_branch" "$remote_url" "$storage_dir"; then
        echo "$(gettext "Repository cloned successfully to") $storage_dir"
        return 0
    else
        echo "$(gettext "Error: Failed to clone repository.")"
        return 1
    fi
}
