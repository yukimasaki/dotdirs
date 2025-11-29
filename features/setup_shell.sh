#!/bin/bash

# /**
#  * @function setup_shell
#  * @description シンボリックリンクの作成とPATHの更新を行い、シェル環境のセットアップを行う。
#  * @param {string} install_dir - プロジェクトがインストールされているディレクトリ。
#  * @returns {number} 成功時は0、失敗時は1。
#  */
# 内部関数: 実際のシェル設定ロジック
_configure_shell() {
    local install_dir="$1"
    local bin_dir="${install_dir}/bin"
    local rein_link="${bin_dir}/rein"
    local main_script="${install_dir}/main.sh"

    # シンボリックリンクを作成
    if [ ! -d "$bin_dir" ]; then
        mkdir -p "$bin_dir"
    fi

    if [ -f "$main_script" ]; then
        ln -sf "$main_script" "$rein_link"
        echo "Created symlink: $rein_link -> $main_script"
    else
        echo "Error: main.sh not found at $main_script"
        return 1
    fi

    # シェルを検出し、PATHを設定
    local shell_name=$(basename "$SHELL")
    local config_file=""
    local path_cmd="export PATH=\"\$PATH:$bin_dir\""

    case "$shell_name" in
        bash)
            config_file="$HOME/.bashrc"
            ;;
        zsh)
            config_file="$HOME/.zshrc"
            ;;
        fish)
            config_file="$HOME/.config/fish/config.fish"
            # Fishの構文は異なる
            path_cmd="set -gx PATH \$PATH $bin_dir"
            ;;
        *)
            echo "Unsupported shell: $shell_name"
            echo "Please manually add $bin_dir to your PATH."
            return 0
            ;;
    esac

    if [ -n "$config_file" ]; then
        if [ ! -f "$config_file" ]; then
            echo "Config file not found: $config_file"
            echo "Creating empty config file..."
            mkdir -p "$(dirname "$config_file")"
            touch "$config_file"
        fi

        # 既に追加されているか確認
        if grep -q "$bin_dir" "$config_file"; then
            echo "PATH already configured in $config_file"
        else
            echo "" >> "$config_file"
            echo "# Added by Rein init script" >> "$config_file"
            echo "$path_cmd" >> "$config_file"
            echo "Added $bin_dir to PATH in $config_file"
            echo "Please restart your shell or source $config_file to apply changes."
        fi
    fi

}

# /**
#  * @function setup_shell
#  * @description シェル環境のセットアップを行う（TUI対応）。
#  * @param {string} install_dir - プロジェクトがインストールされているディレクトリ。
#  * @returns {number} 成功時は0、失敗時は1。
#  */
setup_shell() {
    local install_dir="$1"
    
    if command -v gum &> /dev/null; then
        gum style \
            --foreground 212 --border-foreground 212 --border double \
            --align center --width 50 --margin "1 2" --padding "2 4" \
            "Rein Installer" "Interactive Setup"
        
        echo "Installing Rein to $install_dir..."
        
        # _configure_shell をエクスポートしてサブプロセスで使えるようにする
        export -f _configure_shell
        gum spin --spinner dot --title "Setting up shell..." -- bash -c "_configure_shell \"$install_dir\""
    else
        echo "Installing Rein to $install_dir..."
        _configure_shell "$install_dir"
    fi
}
