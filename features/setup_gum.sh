#!/bin/bash

# /**
#  * @file setup_gum.sh
#  * @description gumのインストールを行う。
#  * Homebrewを使用してインストールする。
#  */

setup_gum() {
    echo "$(gettext "Checking gum...")"

    if command -v gum &> /dev/null; then
        echo "$(gettext "gum is already installed.")"
        return 0
    fi

    if ! command -v brew &> /dev/null; then
        echo "$(gettext "Error: Homebrew is required to install gum but not found.")"
        return 1
    fi

    echo "$(gettext "Installing gum...")"
    brew install gum

    if [ $? -ne 0 ]; then
        echo "$(gettext "Error: Failed to install gum.")"
        return 1
    fi
}
