#!/bin/bash

# ============================================================================
# バックアップ処理
# ============================================================================

# バックアップディレクトリの初期化
initialize_backup_directory() {
    local target_dir="$1"
    echo "${target_dir}/.dotdirs_backup_$(date +%Y%m%d_%H%M%S)"
}

# 既存ファイルをバックアップ
backup_existing_file() {
    local file="$1"
    local backup_dir="$2"
    
    if [ -e "$file" ] && [ ! -L "$file" ]; then
        msg_warning "既存のファイルをバックアップ: $file"
        mkdir -p "$backup_dir"
        cp "$file" "$backup_dir/"
    fi
}


