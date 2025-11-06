#!/bin/bash

# ============================================================================
# fzf インストール・検証処理
# ============================================================================

# fzfのインストール確認
check_fzf_installed() {
    command -v fzf &> /dev/null
}

# fzfのインストール確認とインストール
ensure_fzf_installed() {
    if check_fzf_installed; then
        return 0
    fi
    
    msg_warning "fzf がインストールされていません"
    if ! confirm_yes "fzf をインストールしますか？ (Y/n): " "y"; then
        msg_warning "fzf のインストールをスキップしました"
        msg_warning "setup.sh を使用するか、手動で fzf をインストールしてください"
        exit 1
    fi
    
    install_fzf_via_apt
    verify_fzf_installation
}

# apt経由でfzfをインストール
install_fzf_via_apt() {
    msg_info "fzf をインストール中..."
    
    # 必要なコマンドの存在確認
    if ! command -v apt &> /dev/null; then
        msg_error "エラー: apt が見つかりません"
        msg_warning "Ubuntu/Debian 以外のシステムでは手動で fzf をインストールしてください"
        exit 1
    fi
    
    if ! command -v sudo &> /dev/null; then
        msg_error "エラー: sudo が見つかりません"
        msg_warning "手動で fzf をインストールしてください: sudo apt install fzf"
        exit 1
    fi
    
    # パッケージリストの更新
    msg_warning "パッケージリストを更新中..."
    if ! sudo apt update -qq; then
        msg_error "エラー: パッケージリストの更新に失敗しました"
        exit 1
    fi
    
    # fzfのインストール
    msg_warning "fzf をインストール中..."
    if ! sudo apt install -y fzf; then
        msg_error "エラー: fzf のインストールに失敗しました"
        exit 1
    fi
    
    msg_success "✓ fzf のインストールが完了しました"
    echo ""
}

# fzfのインストール確認
verify_fzf_installation() {
    if ! check_fzf_installed; then
        msg_error "エラー: fzf のインストール後もコマンドが見つかりません"
        msg_warning "シェルを再起動するか、パスを確認してください"
        exit 1
    fi
}


