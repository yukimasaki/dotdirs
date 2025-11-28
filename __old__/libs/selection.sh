#!/bin/bash

# ============================================================================
# 対話的選択処理
# ============================================================================

# fzfでドットファイルを選択
select_dotdirs() {
    local available_files=("$@")
    
    # 説明文は標準エラー出力に出力（fzfの出力と混ざらないように）
    msg_info "シンボリックリンクを作成するドットファイルを選択してください" >&2
    msg_warning "（複数選択可。Tab または Ctrl+Space で選択、Enter で確定）" >&2
    echo "" >&2
    
    # fzfの出力のみを標準出力に出力
    # TabキーとCtrl+Spaceの両方で選択できるようにキーバインドを設定
    printf '%s\n' "${available_files[@]}" | \
        fzf --multi --height=40% --border \
            --bind='tab:toggle+down,btab:toggle+up' \
            --header="ドットファイルを選択 (Tab/Ctrl+Space: 選択, Enter: 確定)"
}

# 選択されたファイルからプレフィックスを削除
clean_selected_files() {
    local selected_files=("$@")
    local cleaned_files=()
    
    for file in "${selected_files[@]}"; do
        # [既にリンク済み] と [除外済み] プレフィックスを削除
        # 両方のパターンがある場合、片方だけの場合を考慮
        cleaned_file=$(echo "$file" | sed 's/^\[既にリンク済み\] \[除外済み\] //' | sed 's/^\[既にリンク済み\] //' | sed 's/^\[除外済み\] //')
        cleaned_files+=("$cleaned_file")
    done
    
    printf '%s\n' "${cleaned_files[@]}"
}

# 選択されたファイルの確認
confirm_selection() {
    local selected_files=("$@")
    
    echo ""
    msg_info "選択されたドットファイル:"
    for file in "${selected_files[@]}"; do
        echo "  - $file"
    done
    echo ""
    
    confirm_yes "シンボリックリンクを作成しますか？ (Y/n): " "y"
}

# .dotdirsignoreからファイルを削除
remove_from_dotdirsignore() {
    local target_dir="$1"
    local file="$2"
    local ignore_file="${target_dir}/.dotdirsignore"
    
    if [ ! -f "$ignore_file" ]; then
        return 0
    fi
    
    # ファイルが存在する場合は削除
    if grep -qxF "$file" "$ignore_file" 2>/dev/null; then
        # 一時ファイルを作成して置き換え
        local temp_file
        temp_file=$(mktemp)
        grep -vx "$file" "$ignore_file" > "$temp_file"
        mv "$temp_file" "$ignore_file"
        return 0
    fi
    
    return 1
}

# 選択しなかったファイルを.dotdirsignoreに追加するか確認
add_unselected_to_dotdirsignore() {
    local target_dir="$1"
    local show_linked="$2"
    local show_ignore="$3"
    shift 3
    local selected_files=("$@")
    
    # フィルタリング済みの利用可能なファイルを取得（実際に選択可能だったファイル）
    local available_files
    readarray -t available_files < <(get_available_dotdirs_filtered "$target_dir" "$show_linked" "$show_ignore")
    
    # 選択されたファイルが.dotdirsignoreに含まれている場合は削除
    local ignore_file="${target_dir}/.dotdirsignore"
    local removed_count=0
    set +e
    for selected_file in "${selected_files[@]}"; do
        # プレフィックスを削除（念のため）
        cleaned_selected=$(echo "$selected_file" | sed 's/^\[既にリンク済み\] \[除外済み\] //' | sed 's/^\[既にリンク済み\] //' | sed 's/^\[除外済み\] //')
        
        if is_ignored_file "$cleaned_selected" "$target_dir"; then
            if remove_from_dotdirsignore "$target_dir" "$cleaned_selected"; then
                msg_success "✓ .dotdirsignore から削除: $cleaned_selected"
                removed_count=$((removed_count + 1))
            fi
        fi
    done
    set -e
    
    # 選択されなかったファイルを取得（フィルタリング済みファイルのみを対象）
    local unselected_files=()
    for file in "${available_files[@]}"; do
        # プレフィックスを削除
        cleaned_file=$(echo "$file" | sed 's/^\[既にリンク済み\] \[除外済み\] //' | sed 's/^\[既にリンク済み\] //' | sed 's/^\[除外済み\] //')
        
        local is_selected=false
        for selected in "${selected_files[@]}"; do
            cleaned_selected=$(echo "$selected" | sed 's/^\[既にリンク済み\] \[除外済み\] //' | sed 's/^\[既にリンク済み\] //' | sed 's/^\[除外済み\] //')
            if [ "$cleaned_file" = "$cleaned_selected" ]; then
                is_selected=true
                break
            fi
        done
        if [ "$is_selected" = false ]; then
            # 既に.dotdirsignoreに含まれているかチェック
            if ! is_ignored_file "$cleaned_file" "$target_dir"; then
                unselected_files+=("$cleaned_file")
            fi
        fi
    done
    
    if [ ${#unselected_files[@]} -eq 0 ]; then
        if [ $removed_count -gt 0 ]; then
            msg_success "$removed_count 個のファイルを .dotdirsignore から削除しました"
        fi
        return 0
    fi
    
    echo ""
    if ! confirm_yes "選択しなかった ${#unselected_files[@]} 個のファイルを .dotdirsignore に追加しますか？ (Y/n): " "y"; then
        return 0
    fi
    
    local ignore_file="${target_dir}/.dotdirsignore"
    local added_count=0
    
    # .dotdirsignoreが存在しない場合は作成
    if [ ! -f "$ignore_file" ]; then
        {
            echo "# dotdirs から除外するファイル"
            echo "# このファイルは setup.sh で自動生成されました"
            echo ""
        } > "$ignore_file"
    fi
    
    # 各ファイルを追加
    set +e
    for file in "${unselected_files[@]}"; do
        # 既に存在するかチェック
        if ! grep -qxF "$file" "$ignore_file" 2>/dev/null; then
            echo "$file" >> "$ignore_file"
            msg_success "✓ .dotdirsignore に追加: $file"
            added_count=$((added_count + 1))
        fi
    done
    set -e
    
    if [ $added_count -gt 0 ]; then
        msg_success "$added_count 個のファイルを .dotdirsignore に追加しました"
    fi
}


