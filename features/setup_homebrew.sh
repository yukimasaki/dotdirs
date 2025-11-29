#!/bin/bash

# /**
#  * @file setup_homebrew.sh
#  * @description HomebrewのインストールとPATH設定を行う。
#  * 既にインストールされている場合はスキップする。
#  */

setup_homebrew() {
    echo "Checking Homebrew..."

    if command -v brew &> /dev/null; then
        echo "Homebrew is already installed."
        return 0
    fi

    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    if [ $? -ne 0 ]; then
        echo "Error: Failed to install Homebrew."
        return 1
    fi

    # Linux用のPATH設定
    local linuxbrew_bin="/home/linuxbrew/.linuxbrew/bin"
    if [ -d "$linuxbrew_bin" ]; then
        echo "Configuring PATH for Homebrew..."
        eval "$($linuxbrew_bin/brew shellenv)"
        
        # 後続のスクリプトのために現在のシェルのPATHに追加
        export PATH="$linuxbrew_bin:$PATH"

        # Fishシェルが検出された場合は設定を永続化
        if [[ "$SHELL" == */fish ]]; then
            if command -v fish_add_path &> /dev/null; then
                fish_add_path "$linuxbrew_bin"
            fi
        fi
    fi
}
