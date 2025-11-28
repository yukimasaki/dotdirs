#!/bin/bash

# /**
#  * @file setup_language.sh
#  * @description 言語選択を行い、環境変数を設定する。
#  */

setup_language() {
    # 言語選択
    if command -v gum &> /dev/null; then
        # gumが使える場合は選択させる
        # まだ言語設定前なので、ここは英語/日本語併記などが親切だが、一旦英語ベースで選択させる
        echo "Select Language / 言語を選択してください:"
        LANG_SELECTION=$(gum choose "English" "Japanese (日本語)")
        
        case "$LANG_SELECTION" in
            "Japanese (日本語)")
                export LC_ALL="ja_JP.UTF-8"
                export LANG="ja_JP.UTF-8"
                ;;
            *)
                export LC_ALL="en_US.UTF-8"
                export LANG="en_US.UTF-8"
                ;;
        esac
    fi
}
