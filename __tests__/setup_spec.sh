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

  Describe "ワークフロー3: --show-linkedオプションを使った既存リンクの確認"
    setup_third_run() {
      cd "$TEST_PROJECT_DIR"
      
      # 既存ファイルを削除
      rm -f "$TEST_PROJECT_DIR/.editorconfig"
      rm -f "$TEST_PROJECT_DIR/.prettierrc"
      
      # .editorconfigのシンボリックリンクを作成
      ln -s "$TEST_CONFIG_DIR/.editorconfig" "$TEST_PROJECT_DIR/.editorconfig"
    }

    BeforeEach 'setup_third_run'

    It "--show-linkedオプションで既存リンクが表示される"
      cd "$TEST_PROJECT_DIR"
      
      # --show-linkedオプションでフィルタリングされたファイルを取得
      result=$(get_available_dotdirs_filtered "$TEST_PROJECT_DIR" "true" "false")
      
      When call echo "$result"
      The output should include "[既にリンク済み] .editorconfig"
      The output should include ".prettierrc"
    End

    It "--show-linkedオプションなしでは既存リンクが表示されない"
      cd "$TEST_PROJECT_DIR"
      
      # --show-linkedオプションなしでフィルタリングされたファイルを取得
      result=$(get_available_dotdirs_filtered "$TEST_PROJECT_DIR" "false" "false")
      
      When call echo "$result"
      The output should not include ".editorconfig"
      The output should include ".prettierrc"
    End
  End

  Describe "ワークフロー4: バックアップ機能のテスト"
    setup_backup_test() {
      cd "$TEST_PROJECT_DIR"
      
      # 既存ファイルを削除
      rm -f "$TEST_PROJECT_DIR/.editorconfig"
      
      # 既存の通常ファイルを作成（バックアップ対象）
      echo "# 既存のeditorconfig" > "$TEST_PROJECT_DIR/.editorconfig"
    }

    BeforeEach 'setup_backup_test'

    It "既存の通常ファイルがある場合、バックアップが作成される"
      cd "$TEST_PROJECT_DIR"
      
      # バックアップディレクトリを初期化
      backup_dir=$(initialize_backup_directory "$TEST_PROJECT_DIR")
      
      # 既存ファイルをバックアップ
      When call backup_existing_file "$TEST_PROJECT_DIR/.editorconfig" "$backup_dir"
      The status should be success
      
      # バックアップファイルが存在することを確認
      # cp "$file" "$backup_dir/" はファイル名を保持する
      backup_file="${backup_dir}/$(basename "$TEST_PROJECT_DIR/.editorconfig")"
      The file "$backup_file" should be exist
      The contents of file "$backup_file" should include "既存のeditorconfig"
      # 出力の確認（警告メッセージ）
      The output should include "既存のファイルをバックアップ"
    End

    It "既存のシンボリックリンクがある場合、バックアップは作成されない"
      cd "$TEST_PROJECT_DIR"
      
      # 既存ファイルを削除
      rm -f "$TEST_PROJECT_DIR/.editorconfig"
      
      # 既存のシンボリックリンクを作成
      ln -s "$TEST_CONFIG_DIR/.editorconfig" "$TEST_PROJECT_DIR/.editorconfig"
      
      # バックアップディレクトリを初期化
      backup_dir=$(initialize_backup_directory "$TEST_PROJECT_DIR")
      
      # 既存のバックアップディレクトリを削除（前のテストの影響を排除）
      rm -rf "$backup_dir"
      
      # 既存ファイルをバックアップ（シンボリックリンクなのでバックアップされない）
      When call backup_existing_file "$TEST_PROJECT_DIR/.editorconfig" "$backup_dir"
      The status should be success
      
      # バックアップファイルが存在しないことを確認
      backup_file="${backup_dir}/$(basename "$TEST_PROJECT_DIR/.editorconfig")"
      The file "$backup_file" should not be exist
    End
  End

  Describe "ワークフロー5: .gitignoreの更新テスト"
    setup_gitignore_test() {
      cd "$TEST_PROJECT_DIR"
      
      # 既存ファイルを削除
      rm -f "$TEST_PROJECT_DIR/.editorconfig"
      rm -f "$TEST_PROJECT_DIR/.gitignore"
      
      # .gitignoreファイルを作成
      echo "# 既存のgitignore" > "$TEST_PROJECT_DIR/.gitignore"
    }

    BeforeEach 'setup_gitignore_test'

    It "シンボリックリンクを作成したファイルが.gitignoreに追加される"
      cd "$TEST_PROJECT_DIR"
      
      # .editorconfigのシンボリックリンクを作成
      create_symlink_for_dotfile ".editorconfig" "$TEST_PROJECT_DIR" "$TEST_PROJECT_DIR/.backup"
      
      # .gitignoreの更新を確認（対話的な確認をスキップ）
      Data "y"
      When call update_gitignore_with_symlinked_files "$TEST_PROJECT_DIR" ".editorconfig"
      
      The status should be success
      The contents of file "$TEST_PROJECT_DIR/.gitignore" should include ".editorconfig"
      The contents of file "$TEST_PROJECT_DIR/.gitignore" should include "dotdirs からシンボリックリンクで管理されているファイルを除外"
      The output should include ".gitignore に追加"
    End

    It ".gitignoreが存在しない場合、自動的に作成される"
      cd "$TEST_PROJECT_DIR"
      
      # .gitignoreを削除
      rm -f "$TEST_PROJECT_DIR/.gitignore"
      
      # .editorconfigのシンボリックリンクを作成
      create_symlink_for_dotfile ".editorconfig" "$TEST_PROJECT_DIR" "$TEST_PROJECT_DIR/.backup"
      
      # .gitignoreの更新を確認（対話的な確認をスキップ）
      Data "y"
      When call update_gitignore_with_symlinked_files "$TEST_PROJECT_DIR" ".editorconfig"
      
      The status should be success
      The file "$TEST_PROJECT_DIR/.gitignore" should be exist
      The contents of file "$TEST_PROJECT_DIR/.gitignore" should include ".editorconfig"
      # メッセージはstderrに出力される
      The error should include ".gitignore が存在しないため、作成します"
      The output should include ".gitignore に追加"
    End

    It "既に.gitignoreに存在するファイルは重複して追加されない"
      cd "$TEST_PROJECT_DIR"
      
      # .gitignoreに.editorconfigを追加
      echo ".editorconfig" >> "$TEST_PROJECT_DIR/.gitignore"
      
      # .editorconfigのシンボリックリンクを作成
      create_symlink_for_dotfile ".editorconfig" "$TEST_PROJECT_DIR" "$TEST_PROJECT_DIR/.backup"
      
      # .gitignoreの更新を確認（対話的な確認をスキップ）
      Data "y"
      When call update_gitignore_with_symlinked_files "$TEST_PROJECT_DIR" ".editorconfig"
      
      The status should be success
      # .editorconfigが1回だけ存在することを確認
      count=$(grep -c "^\.editorconfig$" "$TEST_PROJECT_DIR/.gitignore" || echo "0")
      The value "$count" should eq "1"
      The output should include "既に .gitignore に存在"
    End
  End

  Describe "ワークフロー6: サブディレクトリ内のファイルの管理"
    setup_subdir_test() {
      cd "$TEST_PROJECT_DIR"
      
      # 既存ファイルを削除
      rm -rf "$TEST_PROJECT_DIR/.cursor"
      
      # サブディレクトリ内のファイルを作成
      mkdir -p "$TEST_CONFIG_DIR/.cursor/commands"
      echo "# cursor command" > "$TEST_CONFIG_DIR/.cursor/commands/test.md"
    }

    BeforeEach 'setup_subdir_test'

    It "サブディレクトリ内のファイルが正しく検出される"
      cd "$TEST_PROJECT_DIR"
      
      # 利用可能なファイルを取得
      result=$(get_available_dotdirs)
      
      When call echo "$result"
      The output should include ".cursor/commands/test.md"
    End

    It "サブディレクトリ内のファイルのシンボリックリンクが作成される"
      cd "$TEST_PROJECT_DIR"
      
      # サブディレクトリ内のファイルのシンボリックリンクを作成
      When call create_symlink_for_dotfile ".cursor/commands/test.md" "$TEST_PROJECT_DIR" "$TEST_PROJECT_DIR/.backup"
      The status should be success
      
      # シンボリックリンクが存在することを確認
      The file "$TEST_PROJECT_DIR/.cursor/commands/test.md" should be exist
      The file "$TEST_PROJECT_DIR/.cursor/commands/test.md" should be symlink
      The output should include "シンボリックリンクを作成"
    End

    It "サブディレクトリ内のファイルが.gitignoreに正しく追加される"
      cd "$TEST_PROJECT_DIR"
      
      # サブディレクトリ内のファイルのシンボリックリンクを作成
      create_symlink_for_dotfile ".cursor/commands/test.md" "$TEST_PROJECT_DIR" "$TEST_PROJECT_DIR/.backup"
      
      # .gitignoreの更新を確認（対話的な確認をスキップ）
      Data "y"
      When call update_gitignore_with_symlinked_files "$TEST_PROJECT_DIR" ".cursor/commands/test.md"
      
      The status should be success
      The contents of file "$TEST_PROJECT_DIR/.gitignore" should include ".cursor/commands/test.md"
      The output should include ".gitignore に追加"
    End
  End

  Describe "ワークフロー7: 複数回の実行で段階的にファイルを追加"
    setup_incremental_test() {
      cd "$TEST_PROJECT_DIR"
      
      # 既存ファイルを削除
      rm -f "$TEST_PROJECT_DIR/.editorconfig"
      rm -f "$TEST_PROJECT_DIR/.prettierrc"
      rm -f "$TEST_PROJECT_DIR/.eslintrc"
      rm -f "$TEST_PROJECT_DIR/.gitignore"
      rm -f "$TEST_PROJECT_DIR/.dotdirsignore"
      
      # 追加のドットファイルを作成
      echo "# eslintrc" > "$TEST_CONFIG_DIR/.eslintrc"
      echo "# gitignore" > "$TEST_CONFIG_DIR/.gitignore"
    }

    BeforeEach 'setup_incremental_test'

    It "1回目: .editorconfigのみを選択"
      cd "$TEST_PROJECT_DIR"
      
      # .editorconfigのシンボリックリンクを作成
      create_symlink_for_dotfile ".editorconfig" "$TEST_PROJECT_DIR" "$TEST_PROJECT_DIR/.backup"
      
      # 未選択ファイルを.dotdirsignoreに追加
      Data "y"
      When call add_unselected_to_dotdirsignore "$TEST_PROJECT_DIR" "false" "false" ".editorconfig"
      
      The status should be success
      The contents of file "$TEST_PROJECT_DIR/.dotdirsignore" should include ".prettierrc"
      The contents of file "$TEST_PROJECT_DIR/.dotdirsignore" should include ".eslintrc"
      The contents of file "$TEST_PROJECT_DIR/.dotdirsignore" should include ".gitignore"
      # 出力の確認
      The output should include ".dotdirsignore に追加"
    End

    It "2回目: .prettierrcを追加選択"
      cd "$TEST_PROJECT_DIR"
      
      # 1回目の状態をセットアップ
      rm -f "$TEST_PROJECT_DIR/.editorconfig"
      ln -s "$TEST_CONFIG_DIR/.editorconfig" "$TEST_PROJECT_DIR/.editorconfig"
      {
        echo "# dotdirs から除外するファイル"
        echo ".prettierrc"
        echo ".eslintrc"
        echo ".gitignore"
      } > "$TEST_PROJECT_DIR/.dotdirsignore"
      
      # .prettierrcのシンボリックリンクを作成
      create_symlink_for_dotfile ".prettierrc" "$TEST_PROJECT_DIR" "$TEST_PROJECT_DIR/.backup"
      
      # .prettierrcを選択したので、.dotdirsignoreから削除
      Data "y"
      When call add_unselected_to_dotdirsignore "$TEST_PROJECT_DIR" "false" "true" ".prettierrc"
      
      The status should be success
      The contents of file "$TEST_PROJECT_DIR/.dotdirsignore" should not include ".prettierrc"
      The contents of file "$TEST_PROJECT_DIR/.dotdirsignore" should include ".eslintrc"
      The contents of file "$TEST_PROJECT_DIR/.dotdirsignore" should include ".gitignore"
      # 出力の確認
      The output should include ".dotdirsignore から削除"
    End

    It "3回目: すべてのファイルを選択"
      cd "$TEST_PROJECT_DIR"
      
      # 2回目の状態をセットアップ
      rm -f "$TEST_PROJECT_DIR/.editorconfig"
      rm -f "$TEST_PROJECT_DIR/.prettierrc"
      ln -s "$TEST_CONFIG_DIR/.editorconfig" "$TEST_PROJECT_DIR/.editorconfig"
      ln -s "$TEST_CONFIG_DIR/.prettierrc" "$TEST_PROJECT_DIR/.prettierrc"
      {
        echo "# dotdirs から除外するファイル"
        echo ".eslintrc"
        echo ".gitignore"
      } > "$TEST_PROJECT_DIR/.dotdirsignore"
      
      # 残りのファイルのシンボリックリンクを作成
      create_symlinks_for_selected_files "$TEST_PROJECT_DIR" "$TEST_PROJECT_DIR/.backup" ".eslintrc" ".gitignore"
      
      # すべてのファイルを選択したので、.dotdirsignoreから削除
      Data "n"
      When call add_unselected_to_dotdirsignore "$TEST_PROJECT_DIR" "false" "true" ".eslintrc" ".gitignore"
      
      The status should be success
      The contents of file "$TEST_PROJECT_DIR/.dotdirsignore" should not include ".eslintrc"
      The contents of file "$TEST_PROJECT_DIR/.dotdirsignore" should not include ".gitignore"
      # 出力の確認
      The output should include ".dotdirsignore から削除"
    End
  End

  Describe "ワークフロー8: .dotdirsignoreを手動で編集した場合の動作"
    setup_manual_edit_test() {
      cd "$TEST_PROJECT_DIR"
      
      # .dotdirsignoreを手動で編集（コメントや空行を含む）
      {
        echo "# 手動で追加したコメント"
        echo ""
        echo ".prettierrc"
        echo "# 別のコメント"
        echo ".eslintrc"
        echo ""
      } > "$TEST_PROJECT_DIR/.dotdirsignore"
    }

    BeforeEach 'setup_manual_edit_test'

    It "手動で編集された.dotdirsignoreが正しく読み込まれる"
      cd "$TEST_PROJECT_DIR"
      
      # .dotdirsignoreパターンを取得
      result=$(get_dotdirsignore_patterns "$TEST_PROJECT_DIR")
      
      When call echo "$result"
      The output should include ".prettierrc"
      The output should include ".eslintrc"
      The output should not include "#"
    End

    It "手動で編集された.dotdirsignoreからファイルを削除できる"
      cd "$TEST_PROJECT_DIR"
      
      # .prettierrcを選択してシンボリックリンクを作成
      create_symlink_for_dotfile ".prettierrc" "$TEST_PROJECT_DIR" "$TEST_PROJECT_DIR/.backup"
      
      # .dotdirsignoreから.prettierrcを削除
      When call remove_from_dotdirsignore "$TEST_PROJECT_DIR" ".prettierrc"
      The status should be success
      
      # .dotdirsignoreに.prettierrcが含まれていないことを確認
      The contents of file "$TEST_PROJECT_DIR/.dotdirsignore" should not include ".prettierrc"
      # コメントは残っていることを確認
      The contents of file "$TEST_PROJECT_DIR/.dotdirsignore" should include "手動で追加したコメント"
      The contents of file "$TEST_PROJECT_DIR/.dotdirsignore" should include ".eslintrc"
    End
  End

  Describe "ワークフロー9: 既存のシンボリックリンクを削除して再作成"
    setup_recreate_test() {
      cd "$TEST_PROJECT_DIR"
      
      # 既存ファイルを削除
      rm -f "$TEST_PROJECT_DIR/.editorconfig"
      
      # 既存のシンボリックリンクを作成
      ln -s "$TEST_CONFIG_DIR/.editorconfig" "$TEST_PROJECT_DIR/.editorconfig"
    }

    BeforeEach 'setup_recreate_test'

    It "既存のシンボリックリンクを削除して再作成できる"
      cd "$TEST_PROJECT_DIR"
      
      # 既存のシンボリックリンクを削除
      rm -f "$TEST_PROJECT_DIR/.editorconfig"
      
      # シンボリックリンクを再作成
      When call create_symlink_for_dotfile ".editorconfig" "$TEST_PROJECT_DIR" "$TEST_PROJECT_DIR/.backup"
      The status should be success
      
      # シンボリックリンクが存在することを確認
      The file "$TEST_PROJECT_DIR/.editorconfig" should be exist
      The file "$TEST_PROJECT_DIR/.editorconfig" should be symlink
      # 出力の確認
      The output should include "シンボリックリンクを作成"
    End

    It "既に正しいシンボリックリンクが存在する場合、スキップされる"
      cd "$TEST_PROJECT_DIR"
      
      # 既存のシンボリックリンクに対して再作成を試みる
      When call create_symlink_for_dotfile ".editorconfig" "$TEST_PROJECT_DIR" "$TEST_PROJECT_DIR/.backup"
      The status should be success
      The output should include "既にシンボリックリンクが存在"
      
      # シンボリックリンクが存在することを確認
      The file "$TEST_PROJECT_DIR/.editorconfig" should be exist
      The file "$TEST_PROJECT_DIR/.editorconfig" should be symlink
    End
  End

  Describe "ワークフロー10: エッジケース - 既存の通常ファイルがある場合"
    setup_existing_file_test() {
      cd "$TEST_PROJECT_DIR"
      
      # 既存ファイルを削除（シンボリックリンクも含む）
      rm -f "$TEST_PROJECT_DIR/.editorconfig"
      
      # 既存の通常ファイルを作成
      echo "# プロジェクト固有のeditorconfig" > "$TEST_PROJECT_DIR/.editorconfig"
    }

    BeforeEach 'setup_existing_file_test'

    It "既存の通常ファイルがある場合、シンボリックリンクは作成されない"
      cd "$TEST_PROJECT_DIR"
      
      # シンボリックリンクの作成を試みる
      When call create_symlink_for_dotfile ".editorconfig" "$TEST_PROJECT_DIR" "$TEST_PROJECT_DIR/.backup"
      The status should be failure
      The output should include "既に通常ファイルとして存在します"
      The output should include "プロジェクト固有のファイルの可能性があるため、スキップします"
      
      # 通常ファイルが残っていることを確認
      The file "$TEST_PROJECT_DIR/.editorconfig" should be exist
      The file "$TEST_PROJECT_DIR/.editorconfig" should not be symlink
    End
  End

  Describe "ワークフロー11: 複数のオプションを組み合わせた使用"
    setup_combined_options_test() {
      cd "$TEST_PROJECT_DIR"
      
      # 既存ファイルを削除
      rm -f "$TEST_PROJECT_DIR/.editorconfig"
      rm -f "$TEST_PROJECT_DIR/.prettierrc"
      
      # 既存のシンボリックリンクを作成
      ln -s "$TEST_CONFIG_DIR/.editorconfig" "$TEST_PROJECT_DIR/.editorconfig"
      
      # .dotdirsignoreに.prettierrcを追加
      {
        echo "# dotdirs から除外するファイル"
        echo ".prettierrc"
      } > "$TEST_PROJECT_DIR/.dotdirsignore"
    }

    BeforeEach 'setup_combined_options_test'

    It "--show-linkedと--show-ignoreの両方を指定した場合、すべてのファイルが表示される"
      cd "$TEST_PROJECT_DIR"
      
      # 両方のオプションでフィルタリングされたファイルを取得
      result=$(get_available_dotdirs_filtered "$TEST_PROJECT_DIR" "true" "true")
      
      When call echo "$result"
      The output should include "[既にリンク済み] .editorconfig"
      The output should include "[除外済み] .prettierrc"
    End

    It "--show-linkedと--show-ignoreの両方を指定した場合、除外済みファイルを選択できる"
      cd "$TEST_PROJECT_DIR"
      
      # .prettierrcのシンボリックリンクを作成
      create_symlink_for_dotfile ".prettierrc" "$TEST_PROJECT_DIR" "$TEST_PROJECT_DIR/.backup"
      
      # .prettierrcを選択したので、.dotdirsignoreから削除
      Data "n"
      When call add_unselected_to_dotdirsignore "$TEST_PROJECT_DIR" "true" "true" ".prettierrc"
      
      The status should be success
      The contents of file "$TEST_PROJECT_DIR/.dotdirsignore" should not include ".prettierrc"
      # 出力の確認
      The output should include ".dotdirsignore から削除"
    End
  End
End

