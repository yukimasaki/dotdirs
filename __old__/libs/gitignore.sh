#!/bin/bash

# ============================================================================
# .gitignore 更新処理
# ============================================================================

# .gitignoreファイルの初期化
ensure_gitignore_file() {
    local target_dir="$1"
    local gitignore_file="${target_dir}/.gitignore"
    
    if [ ! -f "$gitignore_file" ]; then
        # メッセージは標準エラー出力に出力（戻り値と混ざらないように）
        msg_warning ".gitignore が存在しないため、作成します" >&2
        # ディレクトリが存在することを確認
        if [ ! -d "$target_dir" ]; then
            msg_error "エラー: ディレクトリ $target_dir が存在しません"
            return 1
        fi
        touch "$gitignore_file" || {
            msg_error "エラー: .gitignore の作成に失敗しました"
            return 1
        }
    fi
    
    # 戻り値としてファイルパスを標準出力に出力
    echo "$gitignore_file"
}

# .gitignoreにセクションを追加
add_gitignore_section_header() {
    local gitignore_file="$1"
    
    if ! grep -q "# dotdirs からシンボリックリンクで管理されているファイルを除外" "$gitignore_file" 2>/dev/null; then
        {
            echo ""
            echo "# dotdirs からシンボリックリンクで管理されているファイルを除外"
            echo "# このセクションは setup.sh で自動生成されました"
        } >> "$gitignore_file"
    fi
}

# .gitignoreにファイルを追加
add_file_to_gitignore() {
    local gitignore_file="$1"
    local file="$2"
    
    # ファイル名の前後の空白を削除
    file=$(echo "$file" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' 2>/dev/null || echo "$file")
    
    if [ -z "$file" ]; then
        return 1
    fi
    
    # 既に存在するかチェック（行頭と行末を正確にマッチ）
    # set -eの影響を回避するため、grepの結果を明示的にチェック
    if grep -qxF "$file" "$gitignore_file" 2>/dev/null; then
        return 1
    fi
    
    # ファイルに追加（set -eの影響を回避）
    {
        echo "$file" >> "$gitignore_file"
    } || {
        msg_error "エラー: .gitignore への書き込みに失敗しました"
        return 1
    }
    return 0
}

# シンボリックリンクされているファイルを.gitignoreに追加
update_gitignore_with_symlinked_files() {
    local target_dir="$1"
    shift
    local symlinked_files=("$@")
    
    local gitignore_file
    gitignore_file=$(ensure_gitignore_file "$target_dir")
    
    echo ""
    if ! confirm_yes ".gitignore を更新しますか？ (Y/n): " "y"; then
        msg_warning ".gitignore の更新をスキップしました"
        return 0
    fi
    
    # セクションヘッダーの追加
    add_gitignore_section_header "$gitignore_file"
    
    # 各ファイルを追加
    local added_count=0
    local file_count=${#symlinked_files[@]}
    
    if [ $file_count -eq 0 ]; then
        return 0
    fi
    
    # 各ファイルを処理（set -eの影響を回避）
    # set -eを一時的に無効化してループを確実に実行
    set +e
    for file in "${symlinked_files[@]}"; do
        # 空の要素をスキップ
        if [ -z "$file" ]; then
            continue
        fi
        
        # ファイル名をクリーンアップ
        local filepath
        filepath=$(echo "$file" | tr -d '\r\n' 2>/dev/null || echo "$file")
        filepath=$(echo "$filepath" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' 2>/dev/null || echo "$filepath")
        
        # パス形式（サブディレクトリ内のファイル）の場合はパス全体を追加
        # ルート直下のファイルの場合はファイル名のみを追加
        local gitignore_entry
        if [[ "$filepath" == */* ]]; then
            # サブディレクトリ内のファイル: パス全体を追加
            gitignore_entry="$filepath"
        else
            # ルート直下のファイル: ファイル名のみを追加
            gitignore_entry=$(basename "$filepath" 2>/dev/null || echo "$filepath")
        fi
        
        # add_file_to_gitignoreを実行
        if add_file_to_gitignore "$gitignore_file" "$gitignore_entry"; then
            msg_success "✓ .gitignore に追加: $gitignore_entry"
            added_count=$((added_count + 1))
        else
            msg_info "既に .gitignore に存在: $gitignore_entry"
        fi
    done
    # set -eを再度有効化
    set -e
    
    if [ $added_count -gt 0 ]; then
        msg_success "$added_count 個のファイルを .gitignore に追加しました"
    else
        msg_info "すべてのファイルは既に .gitignore に追加されています"
    fi
}


