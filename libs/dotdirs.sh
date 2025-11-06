#!/bin/bash

# ============================================================================
# ドットファイル取得処理
# ============================================================================

# ドットファイルのリストを取得（再帰的に検索）
get_available_dotdirs() {
    if [ ! -d "$CONFIG_DIR" ]; then
        return 0
    fi
    # 再帰的に検索し、ドットファイル（.で始まるファイル）またはドットディレクトリ内のファイルを取得
    # -name ".*" : .で始まるファイル（ルート直下）
    # -path "*/.*/*" : ドットディレクトリ内のファイル（例: .cursor/commands/test.md）
    find "$CONFIG_DIR" -type f \( -name ".*" -o -path "*/.*/*" -o -path "*/.?*/*" \) ! -name ".git*" ! -name ".DS_Store" ! -path "*/.git/*" | \
    sed "s|^$CONFIG_DIR/||" | sort
}

# .dotdirsignoreファイルを読み込んで除外パターンを取得
get_dotdirsignore_patterns() {
    local target_dir="$1"
    local ignore_file="${target_dir}/.dotdirsignore"
    
    if [ ! -f "$ignore_file" ]; then
        return 0
    fi
    
    # コメント行と空行を除外
    grep -v '^#\|^$' "$ignore_file" 2>/dev/null || true
}

# ファイルが.dotdirsignoreにマッチするか確認
is_ignored_file() {
    local file="$1"
    local target_dir="$2"
    local patterns
    
    readarray -t patterns < <(get_dotdirsignore_patterns "$target_dir")
    
    # パターンがない場合は除外しない
    if [ ${#patterns[@]} -eq 0 ]; then
        return 1
    fi
    
    for pattern in "${patterns[@]}"; do
        # パターンの前後の空白を削除
        pattern=$(echo "$pattern" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        
        # 空のパターンをスキップ
        if [ -z "$pattern" ]; then
            continue
        fi
        
        # 完全一致またはパターンマッチング
        if [ "$file" = "$pattern" ] || [[ "$file" == */$pattern ]] || [[ "$file" == $pattern/* ]] || [[ "$file" == */$pattern/* ]]; then
            return 0  # マッチした
        fi
    done
    
    return 1  # マッチしなかった
}

# シンボリックリンクされているファイルを取得（再帰的に検索）
get_symlinked_files() {
    local target_dir="$1"
    # 再帰的に検索し、ドットファイル（.で始まるファイル）またはドットディレクトリ内のファイルのシンボリックリンクを取得
    find "$target_dir" -type l \( -name ".*" -o -path "*/.*/*" -o -path "*/.?*/*" \) ! -path "*/.git/*" | \
    while read -r link; do
        local target
        local resolved_target
        
        # readlinkでシンボリックリンクのターゲットを取得
        target=$(readlink "$link")
        
        # 相対パスの場合は絶対パスに変換
        if [[ "$target" != /* ]]; then
            # 相対パスの場合、リンクがあるディレクトリを基準に解決
            local link_dir
            link_dir=$(dirname "$link")
            resolved_target=$(realpath "$link_dir/$target" 2>/dev/null || echo "$target")
        else
            resolved_target="$target"
        fi
        
        # CONFIG_DIRの絶対パスと比較
        local config_dir_abs
        config_dir_abs=$(realpath "$CONFIG_DIR" 2>/dev/null || echo "$CONFIG_DIR")
        
        # ターゲットがCONFIG_DIR内のファイルか確認
        if [[ "$resolved_target" == "$config_dir_abs"/* ]] || [[ "$target" == "$CONFIG_DIR"/* ]] || [[ "$target" == "$DOTDIRS_DIR/config"/* ]]; then
            # ターゲットディレクトリからの相対パスを取得
            # シンボリックリンク自体のパスを返す必要があるため、realpathは使わない
            local relative_path
            if [[ "$link" == "$target_dir"/* ]]; then
                # target_dirからの相対パスを取得
                relative_path="${link#$target_dir/}"
            elif [[ "$link" == "$target_dir" ]]; then
                # リンク自体がtarget_dirの場合（通常は発生しない）
                relative_path=$(basename "$link")
            else
                # フォールバック: basenameを使用
                relative_path=$(basename "$link")
            fi
            echo "$relative_path"
        fi
    done | sort
}

# 除外対象を除外した利用可能なファイルを取得
get_available_dotdirs_filtered() {
    local target_dir="$1"
    local show_linked="${2:-false}"
    local show_ignore="${3:-false}"
    local available_files
    local symlinked_files
    
    # 利用可能なファイルを取得
    readarray -t available_files < <(get_available_dotdirs)
    
    # 既にシンボリックリンクされているファイルを取得
    readarray -t symlinked_files < <(get_symlinked_files "$target_dir")
    
    # 利用可能なファイルをフィルタリング
    for file in "${available_files[@]}"; do
        local is_symlinked=false
        local is_ignored=false
        local should_exclude=false
        
        # 既存のシンボリックリンクをチェック
        for symlinked in "${symlinked_files[@]}"; do
            if [ "$file" = "$symlinked" ]; then
                is_symlinked=true
                # show_linkedがfalseの場合は除外
                if [ "$show_linked" != "true" ]; then
                    should_exclude=true
                fi
                break
            fi
        done
        
        # .dotdirsignoreパターンをチェック
        if is_ignored_file "$file" "$target_dir"; then
            is_ignored=true
            # show_ignoreがfalseの場合は除外
            if [ "$show_ignore" != "true" ]; then
                should_exclude=true
            fi
        fi
        
        # 除外しないファイルを出力
        if [ "$should_exclude" = false ]; then
            local prefix=""
            # プレフィックスを組み立て
            if [ "$is_symlinked" = true ] && [ "$show_linked" = "true" ]; then
                prefix="[既にリンク済み]"
            fi
            if [ "$is_ignored" = true ] && [ "$show_ignore" = "true" ]; then
                if [ -n "$prefix" ]; then
                    prefix="$prefix [除外済み]"
                else
                    prefix="[除外済み]"
                fi
            fi
            
            if [ -n "$prefix" ]; then
                echo "$prefix $file"
            else
                echo "$file"
            fi
        fi
    done
}


