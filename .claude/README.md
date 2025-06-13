[Claude Codeの設定 - Anthropic](https://docs.anthropic.com/ja/docs/claude-code/settings)


> ## 設定の優先順位
> 設定は優先順位の順に適用されます：
> 
> 1. エンタープライズポリシー
> 2. コマンドライン引数
> 3. ローカルプロジェクト設定
> 4. 共有プロジェクト設定
> 5. ユーザー設定
​
## Bedrockで利用するための初期設定

`.claude/settings.local.json` を作成して以下を設定する。
モデルまたは推論プロファイルのIDは各自の環境に合わせる。
AnthropicのAPIで使う場合は不要。

```json
{
  "env": {
    "CLAUDE_CODE_USE_BEDROCK": "true",
    "ANTHROPIC_MODEL": "apac.anthropic.claude-3-7-sonnet-20250219-v1:0",
    "ANTHROPIC_SMALL_FAST_MODEL": "apac.anthropic.claude-3-haiku-20240307-v1:0"
  }
}
```
