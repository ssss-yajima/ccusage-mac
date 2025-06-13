# CLAUDE.md

作業を進めるときは @.claude/todos フォルダに TODOチェックリストを作って、更新しながら作業をしてください。
タスクが増えてきた場合、todoを分割してください。
複数のtodoがある場合、それをまとめた親todoリストを作ってください。


アプリケーション実装時はスキーマ駆動を徹底してください。
テーブル定義やAPI定義、JSONSchema定義、データ加工フローを先に考えてドキュメントや部分的な実装に落とし込みます。
UIを先に考えてはいけません。


This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.



### 設計ドキュメント
以下の設計ドキュメントを必ず参照してください：
- `docs/designdoc.md` - システム全体設計書
- `docs/database-schema.sql` - データベーススキーマ定義
- `docs/api-spec.yaml` - OpenAPI仕様書
- `docs/data-flow.md` - データ処理フロー設計
- `docs/development-tasks.md` - 開発タスク詳細
- `docs/development-checklist.md` - 開発チェックリスト

## Repository Structure

```
.
├── README.md
├── Taskfile.yml               # Task runner configuration
├── biome.jsonc                # Biome.js configuration for linting/formatting
└── docs/
    ├── adr/                   # Architecture Decision Records
    ├── designdoc.md           # System specification document
    ├── feature/               # Gherkin feature files (.feature)
    ├── requirements/          # USDM Requirements files (.yaml)
```

## Development Process

スキーマ駆動開発に従い、以下の順序で開発を進めます：

1. **設計フェーズ**:
   - システム全体設計書の作成・更新
   - データベーススキーマ設計
   - API仕様書作成
   - データ処理フロー設計

2. **実装フェーズ**:
   - データベース環境構築
   - データモデル実装
   - クローラー実装
   - APIサーバー実装
   - フロントエンド実装

3. **品質保証**:
   - ユニットテスト実装
   - 統合テスト実装
   - E2Eテスト実装
   - パフォーマンステスト

4. **デプロイ・運用**:
   - Docker環境構築
   - CI/CD設定
   - 監視・ログ設定

## Technology Stack

### Python
- Web Framework: FastAPI
- CLI Framework: Typer
- Package Management: uv
- Lint/Format: Ruff
- Testing: pytest
- Type Checking: Typing
- Model Definition: Pydantic
- Environment/Configuration: Pydantic-Settings
- Database: SQLite
- ORM: SQLAlchemy
- Crawler: BeautifulSoup + httpx

### TypeScript
- Web Framework: React or Next.js
- Package Management: pnpm
- Lint/Format: Biome.js
- Testing: Vitest
- Validation: Zod

## Commands

### Task Runner

```bash
# List available tasks
task list

# Run default task
task
```

### Python Development

```bash
# Initialize project
uv init --name project_name --python 3.12

# Add dependencies
uv add fastapi uvicorn sqlalchemy pydantic pydantic-settings
uv add beautifulsoup4 httpx typer
uv add --dev ruff pytest pyright pytest-cov

# Run Python code
uv run python entry_point.py
uv run python -m entry.module

# Linting and formatting
uv run ruff check --fix --unsafe-fixes
uv run ruff format

# Run tests
uv run pytest -v --cov
```

### TypeScript Development

```bash
# Project setup (Next.js)
npx create-next-app@latest project_name --ts --tailwind --src-dir --eslint no --use-pnpm --disable-git --app --turbopack --import-alias "@/*"

pnpm add --save-dev --save-exact @biomejs/biome vitest

pnpm biome init --jsonc

# Linting and formatting
npx @biomejs/biome check --write ./src
```
