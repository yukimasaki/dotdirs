#!/usr/bin/env shellspec

Describe "setup.sh 複雑なワークフローテスト"

  setup_test_environment() {
    TEST_DIR=$(mktemp -d)
    TEST_DOTDIRS_DIR="$TEST_DIR/dotdirs"
    TEST_CONFIG_DIR="$TEST_DOTDIRS_DIR/config"
    TEST_PROJECT_DIR="$TEST_DIR/project"
    
    # dotdirsリポジトリの構造を作成
    mkdir -p "$TEST_CONFIG_DIR"
    mkdir -p "$TEST_PROJECT_DIR"
    
    # テスト用のドットファイルを作成
    echo "# editorconfig" > "$TEST_CONFIG_DIR/.editorconfig"
    echo "# prettierrc" > "$TEST_CONFIG_DIR/.prettierrc"
    
    # 環境変数を設定
    export DOTDIRS_DIR="$TEST_DOTDIRS_DIR"
    export CONFIG_DIR="$TEST_CONFIG_DIR"
    export HOME="$TEST_DIR"
    
    # setup.shを読み込む（関数定義を読み込むため）
    # POSIX互換のため、. を使う
    # main関数の実行をスキップするため、環境変数を設定
    export SHELLSPEC_TEST=1
    . "$SHELLSPEC_PROJECT_ROOT/setup.sh"
    unset SHELLSPEC_TEST
  }

  cleanup_test_environment() {
    rm -rf "$TEST_DIR"
  }

  BeforeAll 'setup_test_environment'
  AfterAll 'cleanup_test_environment'

  Describe "ワークフロー1: 1回目の実行"
    It ".editorconfigのみを選択すると、.prettierrcが.dotdirsignoreに追加される"
      cd "$TEST_PROJECT_DIR"
      
      # .editorconfigのみを選択したと仮定
      # 対話的な確認をスキップするため、readコマンドをモック
      Data "y"
      When call add_unselected_to_dotdirsignore "$TEST_PROJECT_DIR" "false" "false" ".editorconfig"
      
      # 出力を確認（警告を回避するため）
      The output should include ".dotdirsignore に追加"
      The status should be success
      The file "$TEST_PROJECT_DIR/.dotdirsignore" should be exist
      The contents of file "$TEST_PROJECT_DIR/.dotdirsignore" should include ".prettierrc"
    End
  End

  Describe "ワークフロー2: 2回目の実行（--show-ignoreオプション付き）"
    setup_second_run() {
      cd "$TEST_PROJECT_DIR"
      
      # 既存ファイルを削除
      rm -f "$TEST_PROJECT_DIR/.editorconfig"
      rm -f "$TEST_PROJECT_DIR/.prettierrc"
      
      # .editorconfigのシンボリックリンクを作成（1回目で作成済み）
      ln -s "$TEST_CONFIG_DIR/.editorconfig" "$TEST_PROJECT_DIR/.editorconfig"
      
      # .dotdirsignoreに.prettierrcを追加（1回目で追加済み）
      {
        echo "# dotdirs から除外するファイル"
        echo "# このファイルは setup.sh で自動生成されました"
        echo ""
        echo ".prettierrc"
      } > "$TEST_PROJECT_DIR/.dotdirsignore"
    }

    BeforeEach 'setup_second_run'

    It ".prettierrcのみが表示され、.editorconfigは表示されない"
      cd "$TEST_PROJECT_DIR"
      
      # --show-ignoreオプションでフィルタリングされたファイルを取得
      result=$(get_available_dotdirs_filtered "$TEST_PROJECT_DIR" "false" "true")
      
      When call echo "$result"
      The output should include "[除外済み] .prettierrc"
      The output should not include ".editorconfig"
    End

    It ".prettierrcを選択すると、.dotdirsignoreから.prettierrcが削除される"
      cd "$TEST_PROJECT_DIR"
      
      # .prettierrcを選択してシンボリックリンクを作成
      create_symlink_for_dotfile ".prettierrc" "$TEST_PROJECT_DIR" "$TEST_PROJECT_DIR/.backup"
      
      # .dotdirsignoreから.prettierrcを削除
      When call remove_from_dotdirsignore "$TEST_PROJECT_DIR" ".prettierrc"
      The status should be success
      
      # .dotdirsignoreに.prettierrcが含まれていないことを確認
      The contents of file "$TEST_PROJECT_DIR/.dotdirsignore" should not include ".prettierrc"
    End

    It ".prettierrcを選択しても、.editorconfigが.dotdirsignoreに追加されない"
      cd "$TEST_PROJECT_DIR"
      
      # .prettierrcのみを選択（フィルタリング済みファイルのみ）
      # 対話的な確認をスキップするため、readコマンドをモック
      # .prettierrcが選択されたので、.dotdirsignoreから削除される
      # 未選択ファイルがないので、追加の確認は表示されない
      Data "n"
      When call add_unselected_to_dotdirsignore "$TEST_PROJECT_DIR" "false" "true" ".prettierrc"
      
      # .prettierrcが.dotdirsignoreから削除されることを確認
      The output should include ".dotdirsignore から削除"
      # .dotdirsignoreに.editorconfigが追加されていないことを確認
      The contents of file "$TEST_PROJECT_DIR/.dotdirsignore" should not include ".editorconfig"
    End
  End
End

