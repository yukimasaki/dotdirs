#!/bin/bash

# /**
#  * @file setup_rules.sh
#  * @description ルールファイルをエディタ・エージェント別の所定ディレクトリにコピーする。
#  * サブディレクトリ構造を維持したままコピーし、エディタに応じてファイル拡張子を変換する。
#  */

# /**
#  * @function select_editor
#  * @description エディタを選択する純粋関数。
#  * @returns {string} 選択されたエディタ名を標準出力に出力
#  */
select_editor() {
    if ! command -v gum &> /dev/null; then
        echo "Error: gum is required but not found." >&2
        return 1
    fi
    
    local editors=("Cursor" "Antigravity")
    echo "Select editor/agent:" >&2
    local selected=$(printf '%s\n' "${editors[@]}" | gum choose)
    
    if [ -z "$selected" ]; then
        return 1
    fi
    
    # 大文字小文字を無視して比較し、小文字で返す
    case "$selected" in
        "Cursor")
            echo "cursor"
            ;;
        "Antigravity")
            echo "antigravity"
            ;;
        *)
            return 1
            ;;
    esac
}

# /**
#  * @function copy_rules_with_structure
#  * @description ルールファイルをサブディレクトリ構造を維持したままコピーする純粋関数。
#  * @param {string} source_dir - ソースディレクトリ（rulesディレクトリのパス）
#  * @param {string} target_base_dir - ターゲットベースディレクトリ（例: $HOME/.cursor）
#  * @param {string} target_subdir - ターゲットサブディレクトリ（例: rules）
#  * @param {string} source_ext - ソースファイル拡張子（例: md）
#  * @param {string} target_ext - ターゲットファイル拡張子（例: mdc）
#  * @returns {number} 成功時は0、失敗時は1
#  */
copy_rules_with_structure() {
    local source_dir="$1"
    local target_base_dir="$2"
    local target_subdir="$3"
    local source_ext="$4"
    local target_ext="$5"
    
    if [ ! -d "$source_dir" ]; then
        echo "Error: Source directory does not exist: $source_dir" >&2
        return 1
    fi
    
    local target_dir="${target_base_dir}/${target_subdir}"
    
    # ターゲットディレクトリが存在しない場合は作成
    if [ ! -d "$target_dir" ]; then
        mkdir -p "$target_dir" || {
            echo "Error: Failed to create target directory: $target_dir" >&2
            return 1
        }
    fi
    
    # ソースディレクトリ内の全ファイルとディレクトリを再帰的に処理
    local copied_count=0
    local failed_count=0
    
    # find コマンドを使って、.md ファイルを再帰的に検索
    # ソースディレクトリのパスを正規化（末尾の/を削除）
    source_dir="${source_dir%/}"
    
    while IFS= read -r -d '' source_file; do
        # ソースディレクトリからの相対パスを取得
        local rel_path="${source_file#$source_dir/}"
        
        # パスの先頭にsource_dirが含まれていない場合（エラーケース）
        if [ "$rel_path" = "$source_file" ]; then
            echo "Warning: Unexpected file path: $source_file" >&2
            ((failed_count++))
            continue
        fi
        
        # ディレクトリ部分を取得
        local rel_dir=$(dirname "$rel_path")
        
        # ファイル名（拡張子なし）を取得
        local filename=$(basename "$rel_path")
        local basename="${filename%.*}"
        
        # ターゲットファイルパスを構築
        local target_file_path=""
        if [ "$rel_dir" = "." ]; then
            # ルートディレクトリのファイル
            target_file_path="${target_dir}/${basename}.${target_ext}"
        else
            # サブディレクトリのファイル
            local target_subdir_path="${target_dir}/${rel_dir}"
            mkdir -p "$target_subdir_path" || {
                echo "Warning: Failed to create subdirectory: $target_subdir_path" >&2
                ((failed_count++))
                continue
            }
            target_file_path="${target_subdir_path}/${basename}.${target_ext}"
        fi
        
        # ファイルをコピー
        if cp "$source_file" "$target_file_path"; then
            ((copied_count++))
        else
            echo "Warning: Failed to copy $source_file to $target_file_path" >&2
            ((failed_count++))
        fi
        
    done < <(find "$source_dir" -type f -name "*.${source_ext}" -print0)
    
    if [ $failed_count -gt 0 ]; then
        echo "Warning: Failed to copy $failed_count file(s)." >&2
    fi
    
    if [ $copied_count -eq 0 ]; then
        echo "Warning: No files were copied." >&2
        return 1
    fi
    
    echo "Copied $copied_count file(s) to $target_dir" >&2
    return 0
}

# /**
#  * @function resolve_target_base_directory
#  * @description ターゲットベースディレクトリの絶対パスを解決する純粋関数。
#  * @param {string} editor - エディタ名
#  * @param {string} custom_path - カスタムパス（オプション）
#  * @returns {string} 絶対パスを標準出力に出力
#  */
resolve_target_base_directory() {
    local editor="$1"
    local custom_path="${2:-}"
    
    if [ -n "$custom_path" ]; then
        local resolved_path=""
        
        # 絶対パスの場合
        if [[ "$custom_path" == /* ]]; then
            resolved_path="$custom_path"
        else
            # 相対パスの場合は絶対パスに変換
            if command -v realpath &> /dev/null; then
                resolved_path=$(realpath -m "$custom_path" 2>/dev/null)
            else
                local current_dir=$(pwd)
                custom_path="${custom_path#./}"
                custom_path="${custom_path%/}"
                if [[ "$custom_path" == .* ]]; then
                    resolved_path="${current_dir}/${custom_path}"
                else
                    resolved_path="${current_dir}/${custom_path}"
                fi
                resolved_path=$(echo "$resolved_path" | sed 's|//|/|g')
            fi
        fi
        
        echo "$resolved_path"
        return 0
    fi
    
    # デフォルトパスを返す
    case "$editor" in
        "cursor")
            echo "$HOME/.cursor"
            ;;
        "antigravity")
            echo "$HOME/.agent"
            ;;
        *)
            echo "$HOME"
            ;;
    esac
}

# /**
#  * @function select_target_directory
#  * @description ターゲットディレクトリを選択する（TUI対応）。
#  * @param {string} editor - エディタ名
#  * @returns {string} 選択されたターゲットベースディレクトリの絶対パスを標準出力に出力
#  */
select_target_directory() {
    local editor="$1"
    
    if ! command -v gum &> /dev/null; then
        echo "Error: gum is required but not found." >&2
        return 1
    fi
    
    gum style \
        --foreground 212 --border-foreground 212 --border double \
        --align center --width 50 --margin "1 2" --padding "2 4" \
        "Rules Setup" "Select target directory"
    
    echo "Select target directory:"
    
    # デフォルトディレクトリを取得
    local default_dir=$(resolve_target_base_directory "$editor")
    
    # よく使われるディレクトリの候補
    local common_dirs=(
        "$default_dir"
        "$HOME/.cursor"
        "$HOME/.agent"
        "$HOME"
        "$(pwd)"
    )
    
    # 既存のディレクトリを候補に追加
    local dir_options=("Custom path...")
    for dir in "${common_dirs[@]}"; do
        if [ -d "$dir" ] && [[ ! " ${dir_options[@]} " =~ " ${dir} " ]]; then
            dir_options+=("$dir")
        fi
    done
    
    local selected_option=$(printf '%s\n' "${dir_options[@]}" | gum choose)
    
    if [ -z "$selected_option" ]; then
        return 1
    fi
    
    local output_dir=""
    if [ "$selected_option" = "Custom path..." ]; then
        # カスタムパス入力
        echo "Enter target directory path (absolute or relative to current directory):"
        output_dir=$(gum input --placeholder "$default_dir" --prompt "> ")
        
        # 空入力の場合、デフォルトディレクトリを使用するか確認
        if [ -z "$output_dir" ]; then
            if gum confirm "Do you want to use default directory ($default_dir)?"; then
                output_dir="$default_dir"
            else
                echo "Error: Target directory is required. Operation cancelled." >&2
                return 1
            fi
        fi
    else
        output_dir="$selected_option"
    fi
    
    # 絶対パスに解決
    local resolved_dir=$(resolve_target_base_directory "$editor" "$output_dir")
    
    # ディレクトリが存在しない場合は作成
    if [ ! -d "$resolved_dir" ]; then
        if gum confirm "Directory $resolved_dir does not exist. Create it?"; then
            mkdir -p "$resolved_dir" || {
                echo "Error: Failed to create directory: $resolved_dir" >&2
                return 1
            }
        else
            echo "Error: Directory does not exist and creation was cancelled." >&2
            return 1
        fi
    fi
    
    echo "$resolved_dir"
    return 0
}

# /**
#  * @function setup_rules
#  * @description ルールファイルをセットアップする（TUI対応）。
#  * @param {string} install_dir - プロジェクトがインストールされているディレクトリ。
#  * @param {string} script_dir - スクリプトが存在するディレクトリ（dotdirs）。
#  * @returns {number} 成功時は0、失敗時は1
#  */
setup_rules() {
    local install_dir="$1"
    local script_dir="$2"
    
    # ルールディレクトリはSCRIPT_DIR（dotdirs）にある
    local rules_source_dir="${script_dir}/storage/__default__/dynamic/rules"
    
    # ルールディレクトリの存在確認
    if [ ! -d "$rules_source_dir" ]; then
        echo "Error: Rules directory not found at $rules_source_dir" >&2
        return 1
    fi
    
    # gumの確認
    if ! command -v gum &> /dev/null; then
        echo "Error: gum is required but not found." >&2
        echo "Please install gum first using: brew install gum" >&2
        return 1
    fi
    
    # エディタの選択
    gum style \
        --foreground 212 --border-foreground 212 --border double \
        --align center --width 50 --margin "1 2" --padding "2 4" \
        "Rules Setup" "Select editor/agent"
    
    local selected_editor=$(select_editor)
    if [ -z "$selected_editor" ]; then
        echo "Error: Editor selection cancelled." >&2
        return 1
    fi
    
    # エディタ別の設定を取得
    local target_subdir=""
    local target_ext=""
    
    case "$selected_editor" in
        "cursor")
            target_subdir="rules"
            target_ext="mdc"
            ;;
        "antigravity")
            target_subdir="rules"
            target_ext="md"
            ;;
        *)
            echo "Error: Unsupported editor: $selected_editor" >&2
            return 1
            ;;
    esac
    
    # ターゲットディレクトリの選択
    local target_base_dir=$(select_target_directory "$selected_editor")
    if [ -z "$target_base_dir" ]; then
        echo "Error: Target directory selection cancelled." >&2
        return 1
    fi
    
    # 既存ファイルの確認
    local target_dir="${target_base_dir}/${target_subdir}"
    if [ -d "$target_dir" ] && [ "$(ls -A "$target_dir" 2>/dev/null)" ]; then
        if ! gum confirm "Directory $target_dir already exists and contains files. Overwrite existing files?"; then
            echo "Operation cancelled." >&2
            return 0
        fi
    fi
    
    # ルールファイルのコピー
    echo ""
    gum style \
        --foreground 212 --border-foreground 212 --border double \
        --align center --width 50 --margin "1 2" --padding "2 4" \
        "Copying Rules" "Copying rules files with directory structure..."
    
    if copy_rules_with_structure "$rules_source_dir" "$target_base_dir" "$target_subdir" "md" "$target_ext"; then
        echo ""
        gum style \
            --foreground 46 --border-foreground 46 --border double \
            --align center --width 50 --margin "1 2" --padding "2 4" \
            "Success" "Rules files copied to:\n${target_dir}"
        return 0
    else
        echo ""
        gum style \
            --foreground 196 --border-foreground 196 --border double \
            --align center --width 50 --margin "1 2" --padding "2 4" \
            "Error" "Failed to copy rules files"
        return 1
    fi
}

