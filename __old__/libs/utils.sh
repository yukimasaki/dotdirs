#!/bin/bash

# ============================================================================
# ユーティリティ関数と定数定義
# ============================================================================

# 色の定義
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# ディレクトリ定数
readonly DOTDIRS_DIR="${HOME}/dotdirs"
readonly CONFIG_DIR="${DOTDIRS_DIR}/config"

# メッセージ出力関数
msg_error() {
    echo -e "${RED}$1${NC}" >&2
}

msg_success() {
    echo -e "${GREEN}$1${NC}"
}

msg_warning() {
    echo -e "${YELLOW}$1${NC}"
}

msg_info() {
    echo -e "${BLUE}$1${NC}"
}

# 確認プロンプト（デフォルトYes）
confirm_yes() {
    local prompt="$1"
    local default="${2:-y}"
    
    msg_info "$prompt"
    read confirm
    
    # デフォルトは[y]（空文字またはEnterキーでも[y]として扱う）
    if [ -z "$confirm" ] || [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
        return 0
    elif [ "$confirm" = "n" ] || [ "$confirm" = "N" ]; then
        return 1
    fi
    
    # デフォルトに応じて返す
    [ "$default" = "y" ]
}


