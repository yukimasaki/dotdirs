#!/bin/bash

# /**
#  * @file init.sh
#  * @description Reinのインストールと初期化を行うエントリーポイントスクリプト。
#  * 必要な機能モジュール（Homebrew, gum, Shell Setup）を順次実行する。
#  */

set -e

# 第一引数はインストールディレクトリ。指定がない場合はカレントディレクトリをデフォルトとする
INSTALL_DIR="${1:-.}"

# 絶対パスを解決する
INSTALL_DIR=$(cd "$INSTALL_DIR" && pwd)

# i18n設定
export TEXTDOMAIN="rein"
export TEXTDOMAINDIR="${INSTALL_DIR}/locales"

# 言語選択モジュールを読み込んで実行
source "${INSTALL_DIR}/features/setup_language.sh"
setup_language

echo "$(gettext "Starting Rein setup...")"

# 機能モジュールを読み込む
source "${INSTALL_DIR}/features/setup_homebrew.sh"
source "${INSTALL_DIR}/features/setup_gum.sh"
source "${INSTALL_DIR}/features/setup_shell.sh"

# 1. Homebrewのセットアップ
if ! setup_homebrew; then
    echo "$(gettext "Failed to setup Homebrew. Exiting.")"
    exit 1
fi

# 2. gumのセットアップ
if ! setup_gum; then
    echo "$(gettext "Failed to setup gum. Exiting.")"
    exit 1
fi

# 3. シェルのセットアップ (gumを使用した対話モード)
# この時点で gum が利用可能になっているはず
if command -v gum &> /dev/null; then
    gum style \
        --foreground 212 --border-foreground 212 --border double \
        --align center --width 50 --margin "1 2" --padding "2 4" \
        "$(gettext "Rein Installer")" "$(gettext "Interactive Setup")"
    
    echo "$(gettext "Installing Rein to") $INSTALL_DIR..."
    
    export -f setup_shell
    gum spin --spinner dot --title "$(gettext "Setting up shell...")" -- bash -c "setup_shell \"$INSTALL_DIR\""
    
    gum style \
        --foreground 82 --border-foreground 82 --border rounded \
        --align center --width 50 --margin "1 2" --padding "2 4" \
        "$(gettext "Installation Complete!")" \
        "$(gettext "Please restart your shell.")"
else
    # gumのインストールに失敗したがスクリプトが継続した場合のフォールバック (set -e があるため通常はここには来ない)
    echo "Installing Rein to $INSTALL_DIR..."
    setup_shell "$INSTALL_DIR"
    echo "$(gettext "Installation Complete!")"
fi
