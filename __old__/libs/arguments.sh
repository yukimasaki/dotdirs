#!/bin/bash

# ============================================================================
# コマンドライン引数解析処理
# ============================================================================

# コマンドライン引数を解析
# 出力: target_dir|show_linked|show_ignore
parse_arguments() {
    local show_linked=false
    local show_ignore=false
    local target_dir=""
    
    while [ $# -gt 0 ]; do
        case "$1" in
            --show-linked)
                show_linked=true
                shift
                ;;
            --show-ignore)
                show_ignore=true
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            -*)
                msg_error "エラー: 不明なオプション: $1"
                echo "使用法: $0 [--show-linked] [--show-ignore] [ターゲットディレクトリ]"
                exit 1
                ;;
            *)
                if [ -z "$target_dir" ]; then
                    target_dir="$(realpath "$1")"
                    if [ ! -d "$target_dir" ]; then
                        msg_error "エラー: $target_dir は存在しません"
                        exit 1
                    fi
                else
                    msg_error "エラー: ターゲットディレクトリは1つだけ指定できます"
                    exit 1
                fi
                shift
                ;;
        esac
    done
    
    # ターゲットディレクトリが指定されていない場合は現在のディレクトリ
    if [ -z "$target_dir" ]; then
        target_dir=$(pwd)
    fi
    
    echo "$target_dir|$show_linked|$show_ignore"
}

# ヘルプメッセージを表示
show_help() {
    local script_name="${0##*/}"
    echo "使用方法: $script_name [オプション] [ターゲットディレクトリ]"
    echo ""
    echo "オプション:"
    echo "  --show-linked    既にリンク済みのファイルもリストに表示"
    echo "  --show-ignore    .dotdirsignoreで除外されているファイルもリストに表示"
    echo "  --help, -h       このヘルプを表示"
    echo ""
    echo "例:"
    echo "  $script_name                         # 現在のディレクトリにシンボリックリンクを作成"
    echo "  $script_name ~/repos/project_a       # 指定したディレクトリにシンボリックリンクを作成"
    echo "  $script_name --show-linked           # 既にリンク済みのファイルも表示"
    echo "  $script_name --show-ignore           # 除外されているファイルも表示"
    echo "  $script_name --show-linked --show-ignore  # 両方のオプションを指定"
}

# 解析結果からターゲットディレクトリを取得
get_target_directory() {
    local result="$1"
    echo "$result" | cut -d'|' -f1
}

# 解析結果からshow_linkedフラグを取得
get_show_linked() {
    local result="$1"
    echo "$result" | cut -d'|' -f2
}

# 解析結果からshow_ignoreフラグを取得
get_show_ignore() {
    local result="$1"
    echo "$result" | cut -d'|' -f3
}


