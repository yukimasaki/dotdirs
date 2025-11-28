#!/bin/bash

# dotdirs セットアップスクリプト
# プロジェクトディレクトリから実行して、対話的にドットファイルのシンボリックリンクを作成
# fzf を使用した高機能な選択UI
#
# 使用方法:
#   ~/dotdirs/setup.sh                    # 現在のディレクトリにシンボリックリンクを作成
#   ~/dotdirs/setup.sh ~/repos/project_a  # 指定したディレクトリにシンボリックリンクを作成

set -e

# ============================================================================
# モジュール読み込み
# ============================================================================

# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="${SCRIPT_DIR}/libs"

# モジュールを読み込み
source "${LIB_DIR}/utils.sh"
source "${LIB_DIR}/arguments.sh"
source "${LIB_DIR}/validation.sh"
source "${LIB_DIR}/fzf.sh"
source "${LIB_DIR}/dotdirs.sh"
source "${LIB_DIR}/backup.sh"
source "${LIB_DIR}/symlink.sh"
source "${LIB_DIR}/gitignore.sh"
source "${LIB_DIR}/selection.sh"

# ============================================================================
# メイン処理
# ============================================================================

# メイン処理
main() {
    # コマンドライン引数を解析
    local result
    result=$(parse_arguments "$@")
    local target_dir
    target_dir=$(get_target_directory "$result")
    local show_linked
    show_linked=$(get_show_linked "$result")
    local show_ignore
    show_ignore=$(get_show_ignore "$result")
    
    validate_environment
    ensure_fzf_installed
    
    # バックアップディレクトリの初期化
    local backup_dir
    backup_dir=$(initialize_backup_directory "$target_dir")
    
    # ヘッダー表示
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}dotdirs セットアップスクリプト${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
    msg_warning "ターゲットディレクトリ: $target_dir"
    msg_warning "dotdirsディレクトリ: $DOTDIRS_DIR"
    echo ""
    
    # 既存リンクの情報を表示
    local symlinked_files
    readarray -t symlinked_files < <(get_symlinked_files "$target_dir")
    local symlinked_count=${#symlinked_files[@]}
    
    if [ "$symlinked_count" -gt 0 ]; then
        if [ "$show_linked" = "true" ]; then
            msg_info "既にリンク済み: $symlinked_count 個（リストに表示）"
        else
            msg_info "既にリンク済み: $symlinked_count 個（表示から除外）"
            msg_info "  --show-linked オプションで表示可能"
        fi
    fi
    
    # .dotdirsignoreの情報を表示
    local ignore_patterns
    readarray -t ignore_patterns < <(get_dotdirsignore_patterns "$target_dir")
    local ignored_count=${#ignore_patterns[@]}
    
    if [ "$ignored_count" -gt 0 ]; then
        if [ "$show_ignore" = "true" ]; then
            msg_info ".dotdirsignore で除外: $ignored_count 個（リストに表示）"
        else
            msg_info ".dotdirsignore で除外: $ignored_count 個（表示から除外）"
            msg_info "  --show-ignore オプションで表示可能"
        fi
    fi
    
    echo ""
    
    # フィルタリングされた利用可能なドットファイルの取得
    local available_files
    readarray -t available_files < <(get_available_dotdirs_filtered "$target_dir" "$show_linked" "$show_ignore")
    
    if [ ${#available_files[@]} -eq 0 ]; then
        msg_warning "新しいドットファイルが見つかりません"
        if [ "$symlinked_count" -gt 0 ] || [ "$ignored_count" -gt 0 ]; then
            msg_info "すべてのドットファイルは既にリンク済みか、除外されています"
            if [ "$symlinked_count" -gt 0 ] && [ "$show_linked" != "true" ]; then
                msg_info "  --show-linked オプションで既存リンクを表示できます"
            fi
            if [ "$ignored_count" -gt 0 ] && [ "$show_ignore" != "true" ]; then
                msg_info "  --show-ignore オプションで除外ファイルを表示できます"
            fi
        else
            msg_warning "ドットファイルが見つかりません"
        fi
        exit 0
    fi
    
    # fzfで選択
    local selected_output
    selected_output=$(select_dotdirs "${available_files[@]}")
    
    if [ -z "$selected_output" ]; then
        msg_warning "セットアップをキャンセルしました"
        exit 0
    fi
    
    # 選択されたファイルを配列に変換
    local selected_files
    # fzfの出力を改行で分割して配列に変換
    mapfile -t selected_files <<< "$selected_output"
    
    # 空行を削除し、プレフィックスを削除
    local cleaned_files=()
    for file in "${selected_files[@]}"; do
        if [ -n "$file" ]; then
            # [既にリンク済み] と [除外済み] プレフィックスを削除
            # 両方のパターンがある場合、片方だけの場合を考慮
            cleaned_file=$(echo "$file" | sed 's/^\[既にリンク済み\] \[除外済み\] //' | sed 's/^\[既にリンク済み\] //' | sed 's/^\[除外済み\] //')
            cleaned_files+=("$cleaned_file")
        fi
    done
    selected_files=("${cleaned_files[@]}")
    
    # 確認
    if ! confirm_selection "${selected_files[@]}"; then
        msg_warning "セットアップをキャンセルしました"
        exit 0
    fi
    
    # シンボリックリンクの作成
    echo ""
    create_symlinks_for_selected_files "$target_dir" "$backup_dir" "${selected_files[@]}"
    
    # .gitignoreの更新（選択されたファイルを直接使用）
    if [ ${#selected_files[@]} -gt 0 ]; then
        # 配列を個別の引数として渡す
        update_gitignore_with_symlinked_files "$target_dir" "${selected_files[@]}"
    fi
    
    # 選択しなかったファイルを.dotdirsignoreに追加するか確認
    if [ ${#selected_files[@]} -gt 0 ]; then
        add_unselected_to_dotdirsignore "$target_dir" "$show_linked" "$show_ignore" "${selected_files[@]}"
    fi
    
    # 完了メッセージ
    echo ""
    msg_success "========================================"
    msg_success "セットアップが完了しました！"
    if [ -d "$backup_dir" ]; then
        msg_warning "バックアップは $backup_dir に保存されました"
    fi
    msg_success "========================================"
}

# スクリプト実行（テスト環境ではスキップ）
if [ -z "${SHELLSPEC_TEST:-}" ]; then
    main "$@"
fi
