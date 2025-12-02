#!/bin/bash

# /**
#  * @file setup_mcp_json.sh
#  * @description MCP設定ファイル（mcp.json）をテンプレートから生成する。
#  * テンプレート内の埋め込み変数（${XXX}）を.envから読み取った環境変数と置き換える。
#  * .envの読み込みに失敗した場合は、インタラクティブに設定する。
#  */

# /**
#  * @function _load_env_file
#  * @description .envファイルを読み込んで環境変数として設定する。
#  * @param {string} env_file - .envファイルのパス
#  * @returns {number} 成功時は0、失敗時は1
#  */
_load_env_file() {
    local env_file="$1"
    
    if [ ! -f "$env_file" ]; then
        return 1
    fi
    
    # .envファイルを読み込む（コメントと空行を除外）
    while IFS= read -r line || [ -n "$line" ]; do
        # コメント行と空行をスキップ
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ -z "${line// }" ]] && continue
        
        # KEY=VALUE形式を環境変数としてエクスポート
        if [[ "$line" =~ ^[[:space:]]*([^=]+)=(.*)$ ]]; then
            local key="${BASH_REMATCH[1]// /}"
            local value="${BASH_REMATCH[2]}"
            # クォートを削除
            value="${value#\"}"
            value="${value%\"}"
            value="${value#\'}"
            value="${value%\'}"
            export "$key=$value"
        fi
    done < "$env_file"
    
    return 0
}

# /**
#  * @function _extract_variables
#  * @description テンプレートファイルから埋め込み変数（${XXX}）を抽出する。
#  * @param {string} template_file - テンプレートファイルのパス
#  * @returns {string} 変数名のリスト（改行区切り）
#  */
_extract_variables() {
    local template_file="$1"
    
    if [ ! -f "$template_file" ]; then
        echo ""
        return 1
    fi
    
    # ${XXX}形式の変数を抽出
    grep -oE '\$\{[A-Za-z_][A-Za-z0-9_]*\}' "$template_file" | \
        sed 's/\${\([^}]*\)}/\1/' | \
        sort -u
}

# /**
#  * @function _replace_variable_in_json
#  * @description JSONファイル内の変数を置き換える。
#  * @param {string} json_file - JSONファイルのパス
#  * @param {string} var_name - 変数名（${}なし）
#  * @param {string} value - 置き換える値
#  * @returns {number} 成功時は0、失敗時は1
#  */
_replace_variable_in_json() {
    local json_file="$1"
    local var_name="$2"
    local value="$3"
    
    # エスケープ処理（JSONの特殊文字をエスケープ）
    local escaped_value=$(echo "$value" | sed 's/\\/\\\\/g; s/"/\\"/g; s/\//\\\//g')
    
    # ${VAR_NAME}を値で置き換え
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS用
        sed -i '' "s|\${${var_name}}|${escaped_value}|g" "$json_file"
    else
        # Linux用
        sed -i "s|\${${var_name}}|${escaped_value}|g" "$json_file"
    fi
}

# /**
#  * @function _interactive_setup_variable
#  * @description 変数をインタラクティブに設定する。
#  * @param {string} var_name - 変数名
#  * @returns {string} 設定された値
#  */
_interactive_setup_variable() {
    local var_name="$1"
    local current_value="${!var_name}"
    
    if [ -n "$current_value" ]; then
        if gum confirm "Variable ${var_name} is already set to: ${current_value}\nDo you want to use this value?"; then
            echo "$current_value"
            return 0
        fi
    fi
    
    echo "Enter value for ${var_name}:" >&2
    gum input --placeholder "Enter ${var_name} value"
}

# /**
#  * @function _process_template
#  * @description テンプレートファイルを処理して変数を置き換える。
#  * @param {string} template_file - テンプレートファイルのパス
#  * @param {string} output_file - 出力ファイルのパス
#  * @param {string} env_file - .envファイルのパス（オプション）
#  * @returns {number} 成功時は0、失敗時は1
#  */
_process_template() {
    local template_file="$1"
    local output_file="$2"
    local env_file="${3:-}"
    
    # テンプレートファイルをコピー
    if ! cp "$template_file" "$output_file"; then
        echo "Error: Failed to copy template file."
        return 1
    fi
    
    # .envファイルを読み込む（存在する場合）
    if [ -n "$env_file" ] && [ -f "$env_file" ]; then
        echo "Loading environment variables from .env file..."
        _load_env_file "$env_file"
    fi
    
    # 埋め込み変数を抽出
    local variables=$(_extract_variables "$output_file")
    
    if [ -z "$variables" ]; then
        echo "No variables found in template."
        return 0
    fi
    
    # 各変数を処理
    local missing_vars=()
    while IFS= read -r var_name; do
        if [ -z "$var_name" ]; then
            continue
        fi
        
        local value="${!var_name}"
        
        if [ -z "$value" ]; then
            missing_vars+=("$var_name")
        else
            echo "Replacing ${var_name} with value from environment..."
            _replace_variable_in_json "$output_file" "$var_name" "$value"
        fi
    done <<< "$variables"
    
    # 未設定の変数をインタラクティブに設定
    if [ ${#missing_vars[@]} -gt 0 ]; then
        echo ""
        if command -v gum &> /dev/null; then
            gum style \
                --foreground 212 --border-foreground 212 --border double \
                --align center --width 50 --margin "1 2" --padding "2 4" \
                "MCP Configuration" "Setting up missing variables"
        fi
        
        echo "The following variables are not set:"
        for var_name in "${missing_vars[@]}"; do
            echo "  - ${var_name}"
        done
        echo ""
        
        if ! gum confirm "Do you want to set these variables interactively?"; then
            echo "Warning: Some variables are not set. The output file may contain unresolved variables."
            return 0
        fi
        
        for var_name in "${missing_vars[@]}"; do
            local value=$(_interactive_setup_variable "$var_name")
            if [ -n "$value" ]; then
                export "$var_name=$value"
                _replace_variable_in_json "$output_file" "$var_name" "$value"
            fi
        done
    fi
    
    return 0
}

# /**
#  * @function setup_mcp_json
#  * @description MCP設定ファイルをセットアップする（TUI対応）。
#  * @param {string} install_dir - プロジェクトがインストールされているディレクトリ。
#  * @param {string} script_dir - スクリプトが存在するディレクトリ（dotdirs）。
#  * @returns {number} 成功時は0、失敗時は1
#  */
setup_mcp_json() {
    local install_dir="$1"
    local script_dir="$2"
    # テンプレートファイルはSCRIPT_DIR（dotdirs）にある
    local template_file="${script_dir}/storage/__default__/dynamic/mcp.template.json"
    
    # テンプレートファイルの存在確認
    if [ ! -f "$template_file" ]; then
        echo "Error: Template file not found at $template_file"
        return 1
    fi
    
    # gumの確認
    if ! command -v gum &> /dev/null; then
        echo "Error: gum is required but not found."
        echo "Please install gum first using: brew install gum"
        return 1
    fi
    
    # 出力ディレクトリの選択
    gum style \
        --foreground 212 --border-foreground 212 --border double \
        --align center --width 50 --margin "1 2" --padding "2 4" \
        "MCP Configuration Setup" "Select output directory"
    
    echo "Select output directory:"
    local output_dir=""
    
    # よく使われるディレクトリの候補
    local common_dirs=(
        "$HOME/.config/cursor"
        "$HOME/.cursor"
        "$HOME/.config"
        "$(pwd)"
    )
    
    # 既存のディレクトリを候補に追加
    local dir_options=("Custom path...")
    for dir in "${common_dirs[@]}"; do
        if [ -d "$dir" ]; then
            dir_options+=("$dir")
        fi
    done
    
    local selected_option=$(printf '%s\n' "${dir_options[@]}" | gum choose)
    
    if [ "$selected_option" = "Custom path..." ]; then
        # カスタムパス入力（gum inputを使用）
        echo "Enter output directory path (absolute or relative to current directory):"
        output_dir=$(gum input --placeholder "$(pwd)" --prompt "> ")
        
        # 空入力の場合、カレントディレクトリを使用するか確認
        if [ -z "$output_dir" ]; then
            if gum confirm "Do you want to create mcp.json in the current directory ($(pwd))?"; then
                output_dir="$(pwd)"
            else
                echo "Error: Output directory is required. Operation cancelled."
                return 1
            fi
        fi
    else
        output_dir="$selected_option"
    fi
    
    if [ -z "$output_dir" ]; then
        echo "Error: Output directory is required."
        return 1
    fi
    
    # 相対パスの場合は絶対パスに変換（init.shを実行している場所を基準）
    if [[ "$output_dir" != /* ]]; then
        # realpathコマンドが利用可能な場合は使用（-mオプションで存在しないパスも処理可能）
        if command -v realpath &> /dev/null; then
            output_dir=$(realpath -m "$output_dir" 2>/dev/null)
        else
            # realpathが使えない場合は、カレントディレクトリを基準に絶対パスに変換
            local current_dir=$(pwd)
            # パスを正規化（先頭の./を削除、末尾の/を削除）
            output_dir="${output_dir#./}"
            output_dir="${output_dir%/}"
            # 絶対パスに変換
            if [[ "$output_dir" == .* ]]; then
                # . や .. で始まる場合
                output_dir="${current_dir}/${output_dir}"
            else
                # 通常の相対パス
                output_dir="${current_dir}/${output_dir}"
            fi
            # パス内の//を/に置換
            output_dir=$(echo "$output_dir" | sed 's|//|/|g')
        fi
    fi
    
    # ディレクトリが存在しない場合は作成
    if [ ! -d "$output_dir" ]; then
        if gum confirm "Directory $output_dir does not exist. Create it?"; then
            mkdir -p "$output_dir"
        else
            echo "Error: Directory does not exist and creation was cancelled."
            return 1
        fi
    fi
    
    local output_file="${output_dir}/mcp.json"
    
    # 既存ファイルの確認
    if [ -f "$output_file" ]; then
        if ! gum confirm "File $output_file already exists. Overwrite?"; then
            echo "Operation cancelled."
            return 0
        fi
    fi
    
    # .envファイルの場所を確認
    local env_file=""
    local env_candidates=(
        "${output_dir}/.env"
        "${install_dir}/.env"
        "$HOME/.env"
        "$(pwd)/.env"
    )
    
    for candidate in "${env_candidates[@]}"; do
        if [ -f "$candidate" ]; then
            if gum confirm "Found .env file at: $candidate\nDo you want to use it?"; then
                env_file="$candidate"
                break
            fi
        fi
    done
    
    # .envファイルが見つからない場合
    if [ -z "$env_file" ]; then
        echo "No .env file found or selected."
        if gum confirm "Do you want to specify a custom .env file path?"; then
            echo "Enter .env file path:"
            env_file=$(gum input --placeholder "Path to .env file" --prompt "> ")
            if [ -z "$env_file" ]; then
                echo "Error: .env file path is required. Operation cancelled."
                return 1
            fi
        fi
    fi
    
    # テンプレートを処理
    echo ""
    if _process_template "$template_file" "$output_file" "$env_file"; then
        echo ""
        gum style \
            --foreground 46 --border-foreground 46 --border double \
            --align center --width 50 --margin "1 2" --padding "2 4" \
            "Success" "MCP configuration file created at:\n$output_file"
        return 0
    else
        echo ""
        gum style \
            --foreground 196 --border-foreground 196 --border double \
            --align center --width 50 --margin "1 2" --padding "2 4" \
            "Error" "Failed to create MCP configuration file"
        return 1
    fi
}

