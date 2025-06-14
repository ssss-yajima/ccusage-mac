# GitHub Releases 配布ガイド

## 概要

GitHub Releases を使って無料でアプリを配布する方法です。

## リリース方法

### 1. バージョンタグを作成してプッシュ

```bash
# バージョンタグを作成
git tag -a v1.0.0 -m "Initial release"

# タグをプッシュ（自動的にビルドが開始されます）
git push origin v1.0.0
```

### 2. 自動ビルドの確認

1. GitHub リポジトリの「Actions」タブを開く
2. 「Build and Release」ワークフローが実行されているのを確認
3. 完了まで約5分待つ

### 3. リリースページの確認

1. 「Releases」タブを開く
2. 新しいリリースが作成されていることを確認
3. 以下のファイルがアップロードされています：
   - `CCUsageMac-v1.0.0.zip` - ZIP形式
   - `CCUsageMac-v1.0.0.dmg` - DMG形式

## インストール方法（ユーザー向け）

### 方法1: DMGファイルを使用

1. Releases ページから `CCUsageMac-v1.0.0.dmg` をダウンロード
2. DMGファイルをダブルクリック
3. `CCUsageMac.app` を Applications フォルダにドラッグ&ドロップ
4. Applications フォルダから CCUsageMac を起動

### 方法2: ZIPファイルを使用

1. Releases ページから `CCUsageMac-v1.0.0.zip` をダウンロード
2. ZIPファイルをダブルクリックして解凍
3. `CCUsageMac.app` を Applications フォルダに移動
4. Applications フォルダから CCUsageMac を起動

### 初回起動時の注意

macOS のセキュリティ機能により、初回起動時に警告が表示されます：

1. 「"CCUsageMac"は、開発元を検証できないため開けません」と表示される
2. システム設定 → プライバシーとセキュリティ を開く
3. 「このまま開く」をクリック
4. パスワードを入力して許可

## 手動ビルド（開発者向け）

GitHub Actions を使わずに手動でリリースする場合：

```bash
# 1. ローカルでビルド
./scripts/build-local.sh

# 2. ZIP作成
cd release
zip -r CCUsageMac-v1.0.0.zip CCUsageMac.app
cd ..

# 3. DMG作成
mkdir dmg-temp
cp -R release/CCUsageMac.app dmg-temp/
hdiutil create -volname "CCUsageMac" -srcfolder dmg-temp -ov -format UDZO CCUsageMac-v1.0.0.dmg
rm -rf dmg-temp

# 4. GitHub Releases ページで手動アップロード
```

## よくある質問

### Q: なぜ警告が出るの？

A: Apple の証明書で署名されていないアプリは、初回起動時に警告が表示されます。これは正常な動作です。

### Q: 毎回警告が出る？

A: いいえ、一度許可すれば次回からは警告なしで起動できます。

### Q: より簡単にインストールできるようにしたい

A: 現在の macOS のセキュリティポリシーでは、署名なしアプリは初回起動時に必ず警告が表示されます。

### Q: ウイルスの心配は？

A: ソースコードは公開されており、GitHub Actions で自動ビルドされているため、安全です。

## バージョン管理

新しいバージョンをリリースする場合：

```bash
# 1. バージョンを更新
# CCUsageMac/Sources/App.swift の appVersion を更新

# 2. 変更をコミット
git add .
git commit -m "Bump version to 1.1.0"

# 3. タグを作成してプッシュ
git tag -a v1.1.0 -m "Release version 1.1.0"
git push origin main
git push origin v1.1.0
```

自動的に新しいリリースが作成されます。