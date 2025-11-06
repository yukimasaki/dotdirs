#!/bin/bash

# ============================================================================
# 環境検証処理
# ============================================================================

# 環境の検証
validate_environment() {
    if [ ! -d "$DOTDIRS_DIR" ]; then
        msg_error "エラー: $DOTDIRS_DIR が見つかりません"
        exit 1
    fi
    
    if [ ! -d "$CONFIG_DIR" ]; then
        msg_warning "警告: $CONFIG_DIR が見つかりません"
    fi
}


