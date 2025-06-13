# Mastra AIエージェント開発 TODO

## ✅ 完了したタスク

### Phase 1: 基盤整備
- [x] MCP経由でKnowledge Base検索機能の実装（エージェント作成済み、AWS設定待ち）
- [x] @modelcontextprotocol/server-aws-kb-retrievalパッケージのインストール
- [x] KB検索エージェントの作成

### Phase 2: Web検索機能強化
- [x] 既存web-search-tool.tsの分析
- [x] enhanced-web-search-tool.tsの作成（キャッシュ、複数プロバイダー対応）
- [x] 重複コードの削除とリファクタリング

### Phase 3: 統合リサーチ機能
- [x] integrated-research-agent.tsの作成
- [x] 複数情報源の統合ロジック実装
- [x] レポート生成機能の実装

### Phase 4: Slack統合
- [x] @modelcontextprotocol/server-slackパッケージのインストール
- [x] slack-agent.tsの作成
- [x] orchestrator-agent.tsによる全体調整機能の実装

### Phase 5: テスト環境とドキュメント
- [x] test-agents.tsの作成
- [x] quick-test.shスクリプトの作成
- [x] .env.exampleの作成
- [x] README.mdの作成
- [x] deployment-guide.mdの作成

### リファクタリング
- [x] 未使用の@ai-sdk/anthropic依存関係を削除
- [x] web-search-tool.tsを削除（enhanced版に統合）
- [x] config.tsによるストレージ設定の統一化
- [x] エージェントの遅延初期化実装（MCP接続エラー対策）

## 🔄 進行中のタスク

なし

## 📋 保留中のタスク（設定待ち）

### AWS設定
- [ ] Knowledge Base IDの環境変数設定（KB_ID）
- [ ] AWS認証情報の設定（AWS_REGION, AWS_PROFILE）
- [ ] Knowledge Base接続テスト

### 検索API設定
- [ ] Bing Search APIキーの取得と設定（BING_SEARCH_API_KEY）
- [ ] Google Custom Search APIの設定（必要に応じて）
- [ ] SearXNGインスタンスのセットアップ（オプション）

### Slack設定
- [ ] Slack Appの作成（OAuth & Permissions設定）
- [ ] Bot Token Scopesの設定（chat:write, channels:read, im:read等）
- [ ] Slack Bot Tokenの取得と設定（SLACK_BOT_TOKEN）
- [ ] Slack Team IDの設定（SLACK_TEAM_ID）
- [ ] Event SubscriptionsとSlash Commandsの設定
- [ ] Slack Appのワークスペースへのインストール

## 🚀 次のステップ

1. **動作確認**
   - `npm run dev`でMastra開発サーバーを起動
   - http://localhost:4111/ でPlaygroundにアクセス
   - 各エージェントの基本動作をテスト

2. **本番環境準備**
   - AWS CDKスタックの更新
   - ECS/Lambda/EC2へのデプロイ設定
   - CI/CDパイプラインの構築

3. **機能拡張**
   - エージェント間の高度な連携
   - より洗練されたプロンプトエンジニアリング
   - パフォーマンス最適化

## 📝 メモ

- Mastraフレームワークは非常に強力で、エージェントの作成が簡単
- MCPプロトコルにより、外部サービスとの統合が標準化されている
- 設定が完了すれば、Knowledge BaseやSlackとの連携も容易に実現可能