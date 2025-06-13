# ccusage-mac

Claude Codeの使用料金をMacのメニューバーに表示するアプリケーション

## 概要

ccusage-macは、[ccusage](https://github.com/ryoppippi/ccusage)のMac版として開発されたメニューバーアプリケーションです。Claude Codeが生成するローカルの使用状況データを読み込み、今日の使用料金をリアルタイムで表示します。

## 機能

- 📊 **リアルタイム料金表示**: メニューバーに今日の使用料金を常時表示
- 🔄 **自動更新**: 5分ごとに自動的にデータを更新
- 📈 **詳細情報**: クリックで詳細なトークン使用量を確認
- 🧠 **モデル追跡**: 使用したClaudeモデル（Opus、Sonnet等）の一覧表示
- 🔒 **API Key不要**: Claude Codeの既存データを利用するため認証不要

## インストール

### 必要環境

- macOS 13.0 (Ventura) 以降
- Claude Codeがインストールされていること

### ビルド方法

1. リポジトリをクローン
```bash
git clone https://github.com/ssss-yajima/ccusage-mac.git
cd ccusage-mac
```

2. Swift Package Managerでビルド
```bash
cd CCUsageMac
swift build -c release
```

3. アプリケーションを実行
```bash
.build/release/CCUsageMac
```

### アプリケーションとしてインストール

1. ビルドしたバイナリをApplicationsフォルダにコピー
2. ログイン時に自動起動する場合は、システム設定 > 一般 > ログイン項目に追加

## 使い方

1. アプリケーションを起動すると、メニューバーに脳のアイコンと今日の使用料金が表示されます
2. メニューバーアイコンをクリックすると詳細情報のポップオーバーが表示されます
3. ポップオーバーでは以下の情報を確認できます：
   - 今日の合計使用料金
   - トークン使用量の内訳（Input/Output/Cache）
   - 使用したモデルの一覧
   - 最終更新時刻

## 開発

### プロジェクト構造

```
ccusage-mac/
├── docs/
│   └── development-policy.md  # 開発方針書
├── CCUsageMac/               # Swiftプロジェクト
│   ├── Sources/
│   │   ├── App.swift         # メインアプリケーション
│   │   ├── MenuBarView.swift # メニューバー表示
│   │   ├── ContentView.swift # 詳細ビュー
│   │   └── ...
│   └── Package.swift
└── README.md
```

### 開発方針

詳細な開発方針については[docs/development-policy.md](docs/development-policy.md)を参照してください。

## ライセンス

MIT License

## 注意事項

### 金額の差異について

CCUsageMacとccusageで表示される金額に差が生じる場合があります：

- **タイムゾーンの扱い**: CCUsageMacはローカルタイムゾーン（日本時間）の0:00を基準に「今日」を判定しますが、深夜0時付近のデータの扱いで若干の差異が生じることがあります
- **特殊モデルの扱い**: `<synthetic>`などの特殊なモデルの扱いが異なる場合があります
- より正確な日別集計が必要な場合は、[ccusage](https://github.com/ryoppippi/ccusage)の使用を推奨します

## 謝辞

- [ccusage](https://github.com/ryoppippi/ccusage) - オリジナルのCLIツール
- このプロジェクトはccusageにインスパイアされて作成されました