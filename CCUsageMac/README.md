# CCUsageMac

Claude Codeの使用料金をMacのメニューバーに表示するアプリケーション

![Screenshot](../docs/screenshot.png)

## 概要

CCUsageMacは、Claude Codeが生成するローカルの使用状況データ（`~/.claude/projects/`）を読み込み、今日の使用料金をメニューバーに常時表示するmacOSアプリケーションです。

## 機能

- 📊 **リアルタイム料金表示**: メニューバーに今日の使用料金を表示
- 🔄 **自動更新**: 5分ごとに自動的にデータを更新
- 📈 **詳細情報**: クリックで詳細なトークン使用量を確認
- 🧠 **モデル追跡**: 使用したClaudeモデルの一覧表示
- 🔒 **API Key不要**: Claude Codeの既存データを利用

## 必要環境

- macOS 13.0 (Ventura) 以降
- Xcode 15.0 以降
- Claude Codeがインストールされていること

## ビルド方法

### Swift Package Managerを使用

```bash
cd CCUsageMac
swift build -c release
```

ビルドされたアプリケーションは `.build/release/CCUsageMac` に生成されます。

### Xcodeを使用

1. `Package.swift`をXcodeで開く
2. Product > Archive を選択
3. Distribute App > Copy App を選択

## インストール

1. ビルドしたアプリケーションを `/Applications` フォルダにコピー
2. 初回起動時はシステム設定でアクセス許可が必要な場合があります

## 使い方

1. アプリケーションを起動すると、メニューバーに脳のアイコンと料金が表示されます
2. メニューバーアイコンをクリックすると詳細情報が表示されます
3. 更新ボタンで手動更新も可能です

## 開発

### プロジェクト構造

```
CCUsageMac/
├── Sources/
│   ├── App.swift              # メインアプリケーション
│   ├── MenuBarView.swift      # メニューバー表示
│   ├── ContentView.swift      # 詳細ビュー
│   ├── UsageDetailView.swift  # 使用量詳細表示
│   ├── Models.swift           # データモデル
│   └── UsageDataLoader.swift  # データ読み込みロジック
└── Tests/                     # テストコード
```

### テスト実行

```bash
swift test
```

## ライセンス

MIT License

## 関連プロジェクト

- [ccusage](https://github.com/ryoppippi/ccusage) - コマンドラインツール版