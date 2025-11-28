#!/bin/bash

# ============================================================================
# シンボリックリンク作成処理
# ============================================================================

# シンボリックリンクが有効か確認
is_valid_symlink() {
    local link_path="$1"
    local expected_target="$2"
    
    if [ ! -L "$link_path" ]; then
        return 1
    fi
    
    local actual_target
    local resolved_actual
    local resolved_expected
    
    actual_target=$(readlink "$link_path")
    
    # 絶対パスに変換して比較
    resolved_actual=$(realpath "$link_path" 2>/dev/null)
    resolved_expected=$(realpath "$expected_target" 2>/dev/null)
    
    # 絶対パスで比較できた場合
    if [ -n "$resolved_actual" ] && [ -n "$resolved_expected" ]; then
        [ "$resolved_actual" = "$resolved_expected" ]
        return
    fi
    
    # 相対パスまたは変換できなかった場合は元の比較
    [ "$actual_target" = "$expected_target" ]
}

# シンボリックリンクを作成
create_symlink_for_dotfile() {
    local dotfile="$1"
    local target_dir="$2"
    local backup_dir="$3"
    
    local source_file="${CONFIG_DIR}/${dotfile}"
    local target_file="${target_dir}/${dotfile}"
    
    # ソースファイルの存在確認
    if [ ! -f "$source_file" ]; then
        msg_error "エラー: $source_file が見つかりません"
        return 1
    fi
    
    # 親ディレクトリの作成（サブディレクトリ内のファイルに対応）
    local target_parent
    target_parent=$(dirname "$target_file")
    if [ ! -d "$target_parent" ]; then
        mkdir -p "$target_parent"
    fi
    
    # 既存ファイルが通常ファイルの場合（プロジェクト固有の可能性）
    # このチェックを先に実行する（シンボリックリンクのチェックより先）
    if [ -e "$target_file" ] && [ ! -L "$target_file" ] && [ -f "$target_file" ]; then
        msg_warning "警告: $dotfile は既に通常ファイルとして存在します"
        msg_warning "プロジェクト固有のファイルの可能性があるため、スキップします"
        return 1
    fi
    
    # 既に正しいシンボリックリンクが存在する場合はスキップ
    local source_abs
    source_abs=$(realpath "$source_file" 2>/dev/null || echo "$source_file")
    if is_valid_symlink "$target_file" "$source_abs"; then
        msg_info "既にシンボリックリンクが存在: $dotfile"
        return 0
    fi
    
    # 既存ファイルのバックアップ
    backup_existing_file "$target_file" "$backup_dir"
    
    # 既存のファイルまたはリンクを削除
    if [ -e "$target_file" ]; then
        rm -f "$target_file" || rm -rf "$target_file"
    fi
    
    # シンボリックリンクを作成（絶対パスで作成）
    ln -s "$source_abs" "$target_file" || return 1
    msg_success "✓ シンボリックリンクを作成: $dotfile"
}

# 選択されたドットファイルのシンボリックリンクを作成
create_symlinks_for_selected_files() {
    local target_dir="$1"
    local backup_dir="$2"
    shift 2
    local files=("$@")
    
    for dotfile in "${files[@]}"; do
        create_symlink_for_dotfile "$dotfile" "$target_dir" "$backup_dir"
    done
}


