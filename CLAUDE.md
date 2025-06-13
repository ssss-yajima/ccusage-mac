# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

CCUsageMac is a macOS menu bar application that displays Claude Code usage costs in real-time, equivalent to the `npx ccusage@latest` command.

Reference output:
```
┌──────────────┬──────────────────────────────────────┬──────────────┬──────────────┬──────────────┬──────────────┬──────────────┬────────────┐
│ Date         │ Models                               │        Input │       Output │ Cache Create │   Cache Read │ Total Tokens │ Cost (USD) │
├──────────────┼──────────────────────────────────────┼──────────────┼──────────────┼──────────────┼──────────────┼──────────────┼────────────┤
│ 2025-06-14   │ opus-4, sonnet-4                     │          840 │       25,963 │      684,682 │   19,863,036 │   20,574,521 │     $36.32 │
├──────────────┼──────────────────────────────────────┼──────────────┼──────────────┼──────────────┼──────────────┼──────────────┼────────────┤
│ Total        │                                      │       34,778 │      598,308 │   13,369,976 │  230,114,313 │  244,117,375 │    $381.67 │
└──────────────┴──────────────────────────────────────┴──────────────┴──────────────┴──────────────┴──────────────┴──────────────┴────────────┘
```

The app displays today's usage cost in the menu bar and shows details on hover.

## Development Guidelines

When working on tasks, create TODO checklists in the @.claude/todos folder and update them as you progress.
If tasks grow numerous, split them into separate todo files.
When you have multiple todo files, create a parent todo list that summarizes them.

For application implementation, follow schema-driven development strictly:
- Design table schemas, API definitions, JSONSchema definitions, and data processing flows first
- Document these designs before implementation
- Do not start with UI design

## Development Policy

Refer to the following development policy document:
- `docs/development-policy.md` - Development policy (architecture, tech stack, requirements, etc.)

### Design Documents
Always refer to these design documents:
- `docs/designdoc.md` - System design specification
- `docs/database-schema.sql` - Database schema definitions
- `docs/api-spec.yaml` - OpenAPI specification
- `docs/data-flow.md` - Data processing flow design
- `docs/development-tasks.md` - Development task details
- `docs/development-checklist.md` - Development checklist

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

Following schema-driven development, proceed in this order:

1. **Design Phase**:
   - Create/update system design specification
   - Design database schema
   - Create API specification
   - Design data processing flow

2. **Implementation Phase**:
   - Set up database environment
   - Implement data models
   - Implement crawler
   - Implement API server
   - Implement frontend

3. **Quality Assurance**:
   - Implement unit tests
   - Implement integration tests
   - Implement E2E tests
   - Performance testing

4. **Deployment & Operations**:
   - Docker environment setup
   - CI/CD configuration
   - Monitoring and logging setup

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