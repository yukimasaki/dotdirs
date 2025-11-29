#!/bin/bash

# /**
#  * @file setup_gum.sh
#  * @description gumのインストールを行う。
#  * Homebrewを使用してインストールする。
#  */

setup_gum() {
    echo "Checking gum..."

    if command -v gum &> /dev/null; then
        echo "gum is already installed."
        return 0
    fi

    if ! command -v brew &> /dev/null; then
        echo "Error: Homebrew is required to install gum but not found."
        return 1
    fi

    echo "Installing gum..."
    brew install gum

    if [ $? -ne 0 ]; then
        echo "Error: Failed to install gum."
        return 1
    fi
}
