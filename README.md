# dotdirs

プロジェクト間で散在するドットファイル・ドットディレクトリを一元管理するリポジトリです。

## 概要

複数のプロジェクトで同じ `.editorconfig` や `.prettierrc` などのドットファイルを使い回していると、管理が煩雑になります。このリポジトリでは、ドットファイルを `~/dotdirs` に一元管理し、各プロジェクトからシンボリックリンクで参照することで、一箇所の変更を全プロジェクトに反映できます。

## 機能

- **対話的なセットアップ**: fzf を使用した高機能な選択 UI で、必要なドットファイルだけを選択可能
- **自動シンボリックリンク作成**: 選択したドットファイルを自動的にシンボリックリンクとして作成
- **サブディレクトリ対応**: `.cursor/commands/test.md` のようなサブディレクトリ内のファイルも管理可能
- **既存ファイルの自動バックアップ**: 既存のドットファイルがある場合は自動的にバックアップ
- **プロジェクト固有ファイルの保護**: 既存の通常ファイルはプロジェクト固有の可能性があるため、自動的に保護
- **`.gitignore` 自動更新**: シンボリックリンクを作成したファイルを `.gitignore` に自動追加
- **`.dotdirsignore` による除外管理**: 選択しなかったファイルを `.dotdirsignore` に自動追加して次回の表示から除外
- **既存リンク・除外ファイルの表示オプション**: `--show-linked` と `--show-ignore` オプションで既存リンクや除外ファイルも表示可能
- **fzf 自動インストール**: Ubuntu/Debian 環境で fzf が未インストールの場合、自動インストールを提案
- **モジュール化された構造**: 可読性とメンテナンス性を向上させたモジュール設計

## 使用方法

### クイックスタート

1. **dotdirs リポジトリをクローン**

   ```bash
   git clone <repository-url> ~/dotdirs
   ```

2. **プロジェクトディレクトリに移動**

   ```bash
   cd ~/repos/project_a
   ```

3. **セットアップスクリプトを実行**

   ```bash
   ~/dotdirs/setup.sh
   ```

4. **対話的にドットファイルを選択**

   - fzf UI で必要なドットファイルを選択（Tab または Ctrl+Space で複数選択）
   - Enter で確定

5. **確認プロンプトに Enter を押す**
   - シンボリックリンク作成の確認（デフォルト: y）
   - `.gitignore` 更新の確認（デフォルト: y）

以上で完了です。

### 引数でディレクトリを指定

```bash
# どこからでも実行可能
~/dotdirs/setup.sh ~/repos/project_a
```

### オプション

```bash
# 既にリンク済みのファイルも表示
~/dotdirs/setup.sh --show-linked

# .dotdirsignoreで除外されているファイルも表示
~/dotdirs/setup.sh --show-ignore

# 両方のオプションを指定
~/dotdirs/setup.sh --show-linked --show-ignore ~/repos/project_a

# ヘルプを表示
~/dotdirs/setup.sh --help
```

### 新しいドットファイルを追加する場合

1. `~/dotdirs/config/` ディレクトリにドットファイルを追加
   - ルート直下のファイル: `~/dotdirs/config/.editorconfig`
   - サブディレクトリ内のファイル: `~/dotdirs/config/.cursor/commands/test.md`
2. 各プロジェクトで `~/dotdirs/setup.sh` を実行して選択

## 管理方法

### dotdirs リポジトリの管理

このリポジトリ自体は通常の Git リポジトリとして管理します。

```bash
cd ~/dotdirs
git add config/.editorconfig
git commit -m "Add .editorconfig"
git push
```

### プロジェクトでの管理

- **シンボリックリンクは Git で管理しない**: `.gitignore` に追加されているため、シンボリックリンクはコミットされません
- **ドットファイルの変更は dotdirs リポジトリで管理**: シンボリックリンク経由で編集したファイルは、`~/dotdirs/config/` に反映されます

### プロジェクト固有の設定が必要な場合

プロジェクト側で直接ファイルを作成・管理してください。既存の通常ファイルがある場合、セットアップスクリプトは自動的にスキップして保護します。

**例:**

- 共通ファイル（dotdirs 管理）: `.cursor/commands/common.md` → シンボリックリンク
- プロジェクト固有ファイル（プロジェクト管理）: `.cursor/commands/project_a.md` → 通常ファイル（上書きされない）

### `.dotdirsignore` による除外管理

選択しなかったファイルは `.dotdirsignore` に自動追加され、次回の実行時には表示されません。既にリンク済みのファイルも同様に表示から除外されます。

除外されたファイルを再度表示するには、`--show-ignore` オプションを使用してください。

```bash
# 除外されたファイルも表示
~/dotdirs/setup.sh --show-ignore

# 既存リンクも表示
~/dotdirs/setup.sh --show-linked
```

## ディレクトリ構成

```
~/dotdirs/
├── README.md          # このファイル
├── setup.sh           # セットアップスクリプト（メイン処理）
├── libs/              # モジュール化されたライブラリ
│   ├── utils.sh       # ユーティリティ関数と定数
│   ├── arguments.sh   # 引数解析処理
│   ├── validation.sh  # 環境検証
│   ├── fzf.sh         # fzf インストール・検証
│   ├── dotdirs.sh    # ドットファイル取得・フィルタリング
│   ├── backup.sh      # バックアップ処理
│   ├── symlink.sh     # シンボリックリンク作成
│   ├── gitignore.sh   # .gitignore 更新
│   └── selection.sh   # fzf 選択処理と .dotdirsignore 管理
├── config/            # ドットファイルを格納するディレクトリ
│   ├── .editorconfig
│   ├── .prettierrc
│   ├── .cursor/       # サブディレクトリも管理可能
│   │   └── commands/
│   │       └── test.md
│   └── ...            # その他のドットファイル
└── __tests__/         # テストファイル（ShellSpec）
```

各プロジェクトでは、`config/` 内のドットファイルへのシンボリックリンクが作成されます。

```
~/repos/project_a/
├── .editorconfig              -> ~/dotdirs/config/.editorconfig
├── .prettierrc                -> ~/dotdirs/config/.prettierrc
├── .cursor/                   # サブディレクトリも自動作成
│   └── commands/
│       ├── test.md            -> ~/dotdirs/config/.cursor/commands/test.md
│       └── project_a.md       # プロジェクト固有ファイル（直接管理）
└── ...
```
