# Project Chimera — Autonomous Influencer Network

**An enterprise-grade, cloud-native platform for operating large fleets of persistent AI influencer agents with centralized governance.**

[![CI/CD Pipeline](https://github.com/gemechisworku/10-academy-chimera/actions/workflows/main.yml/badge.svg)](https://github.com/gemechisworku/10-academy-chimera/actions/workflows/main.yml)
[![CodeRabbit](https://img.shields.io/badge/CodeRabbit-AI%20Review-blue)](https://coderabbit.ai)
[![Python](https://img.shields.io/badge/Python-3.13+-blue.svg)](https://www.python.org/downloads/)
[![License](https://img.shields.io/badge/License-TBD-lightgrey.svg)](LICENSE)

> **Note**: Replace `YOUR_USERNAME` in the CI/CD badge URL with your actual GitHub username/organization.

---

## Overview

Project Chimera (AiQEM Autonomous Influencer Network) is a **hub-and-spoke autonomous agent platform** designed to scale from a single operator to managing **1,000+ persistent influencer agents** simultaneously. Unlike consumer-grade AI assistants, Chimera enforces enterprise-level governance, safety, and economic controls while enabling high-velocity content generation and multi-platform engagement.

### Key Differentiators

- **Enterprise-Grade Governance**: Human-in-the-Loop (HITL) routing, confidence thresholds, policy enforcement, and budget governors
- **Hierarchical Swarm Architecture**: Each agent operates as a Planner–Worker–Judge swarm for parallel execution and quality control
- **MCP-Only External Interface**: All external interactions routed through Model Context Protocol (MCP) servers for platform volatility isolation
- **Optimistic Concurrency Control (OCC)**: Prevents ghost updates and ensures state consistency across thousands of parallel workers
- **Agentic Commerce**: Non-custodial wallets and CFO Judge patterns enable economically autonomous agents

---

## Architecture

### Core Pattern: Hub-and-Spoke

- **Hub (Central Orchestrator)**: Control plane, global state management, policy distribution, dashboards
- **Spokes (Agent Runtimes)**: Individual agents with internal Planner–Worker–Judge swarms

### Agent Internal Architecture: FastRender Swarm

Each agent is not monolithic but dynamically instantiated as a hierarchical swarm:

- **Planner**: Decomposes goals into task DAGs, handles dynamic replanning
- **Worker Pool**: Stateless, ephemeral executors that run atomic tasks in parallel
- **Judge**: Enforces quality, policy compliance, safety constraints, OCC commit control, and HITL routing

### Data Layer

- **PostgreSQL**: Transactional metadata, lineage, governance, publishing state
- **Object Storage (S3/GCS)**: Media blobs (renders, thumbnails, intermediates)
- **Redis**: Queues (task, review, HITL) + episodic cache
- **Weaviate**: Vector memory/RAG for long-term context

### MCP Integration Layer

All external capabilities are accessed via MCP servers:
- Social platforms (Twitter, Instagram)
- Content generation (Runway, Luma, Ideogram, Midjourney)
- Web/search capabilities
- Agentic commerce (Coinbase AgentKit)

---

## Governance & Safety

### Human-in-the-Loop (HITL) Routing

The Judge routes artifacts based on confidence scores and risk assessment:

- **High confidence (>0.90)**: Auto-approve and execute
- **Medium confidence (0.70–0.90)**: Asynchronous human approval (pending)
- **Low confidence (<0.70)**: Reject/auto-retry with improved strategy
- **Sensitive topics**: Mandatory human review regardless of confidence

### Key Safety Features

- **Action-boundary approval**: Humans approve effects (posts, transactions), not intermediate drafts
- **Domain-split Judges**: Content Judge + CFO Judge for specialized governance
- **Policy-driven enforcement**: Hard controls via MCP policy, not just prompt engineering
- **Audit trail**: Complete traceability of approvals, policy versions, and reasoning traces

---

## Project Status

This repository contains the research, architecture documentation, and initial implementation setup for Project Chimera.

### Current Deliverables

- **Research Summary**: Consolidated SRS review and cross-reference analysis
- **Architecture Strategy**: Core domain architecture decisions and technical specifications
- **Technical Specifications**: Complete API contracts, database schemas, and Pydantic models (see `specs/technical.md`)
- **Functional Specifications**: User stories and acceptance criteria (see `specs/functional.md`)
- **Test-Driven Development Setup**: Failing tests that define implementation contracts
- **Containerization**: Docker setup for consistent development environment
- **Automation**: Makefile and PowerShell scripts for standardized workflows

---

## Documentation

### Specifications

- [`specs/_meta.md`](specs/_meta.md) — Core architectural principles and constraints
- [`specs/technical.md`](specs/technical.md) — API contracts, database schemas, and Pydantic models
- [`specs/functional.md`](specs/functional.md) — User stories and acceptance criteria
- [`specs/openclaw_integration.md`](specs/openclaw_integration.md) — OpenClaw network integration patterns

### Research

- [`research/research_summary.md`](research/research_summary.md) — Consolidated SRS review, comparative analysis with OpenClaw/Moltbook, and architectural insights
- [`research/architecture_strategy.md`](research/architecture_strategy.md) — Domain architecture decisions, swarm pattern rationale, HITL design, and data layer choices
- [`research/project_chimera_srs_document.md`](research/project_chimera_srs_document.md) — Complete Software Requirements Specification

### Skills

- [`skills/README.md`](skills/README.md) — Skills interface definitions and execution patterns

---

## Business Model Enablement

Chimera supports three scalable business models:

1. **Digital Talent Agency**: AiQEM-owned influencer agents as revenue assets
2. **Platform-as-a-Service**: Licensed infrastructure for brands and agencies
3. **Hybrid Ecosystem**: Proprietary flagship agents plus third-party developers

---

## Key Architectural Decisions

1. **Hierarchical Swarm over Sequential Chain**: Enables parallelism, governance, and failure isolation
2. **SQL (PostgreSQL) over NoSQL for metadata**: Prioritizes relational integrity, traceability, and governance
3. **Judge-routed HITL**: Safety layer integrated into execution pipeline, not bolted on
4. **MCP-only external effects**: Centralized logging, rate limiting, and provider swapping

---

## Technology Stack

- **Runtime**: Python 3.13+ with MCP client integration
- **Package Management**: `uv` for fast dependency resolution
- **Orchestration**: Central Orchestrator (control plane)
- **Databases**: PostgreSQL (transactional), Weaviate (vector), Redis (queues/cache)
- **Storage**: Object storage (S3/GCS) for media blobs
- **Protocol**: Model Context Protocol (MCP) for all external interactions
- **Blockchain**: On-chain ledger integration for agentic commerce
- **Containerization**: Docker for consistent development environments
- **Testing**: pytest with TDD workflow

---

## Development Setup

### Prerequisites

- **Python**: 3.13 or higher
- **uv**: Python package manager (install from [https://github.com/astral-sh/uv](https://github.com/astral-sh/uv))
- **Docker**: For containerized testing (optional but recommended)

### Quick Start

#### Option 1: Using PowerShell Script (Recommended for Windows)

We provide a PowerShell script (`make.ps1`) that works on Windows without additional installations:

```powershell
# Install dependencies
.\make.ps1 setup

# Run tests in Docker
.\make.ps1 test

# Run spec-check to verify code alignment
.\make.ps1 spec-check

# Build Docker image
.\make.ps1 docker-build

# Clean build artifacts
.\make.ps1 clean
```

#### Option 2: Using Make (Linux/macOS or Windows with WSL)

If you have `make` installed:

```bash
# Install dependencies
make setup

# Run tests in Docker
make test

# Run spec-check
make spec-check

# Build Docker image
make docker-build

# Clean build artifacts
make clean
```

#### Option 3: Manual Setup

```bash
# Install dependencies using uv
uv pip install -e ".[dev]"

# Run tests locally (requires dependencies installed)
pytest tests/ -v

# Run spec-check script
./scripts/spec-check.sh  # Linux/macOS
# or
powershell -ExecutionPolicy Bypass -File scripts/spec-check.ps1  # Windows
```

### Test-Driven Development (TDD)

The project follows a TDD approach. Currently, all tests are **expected to fail** because implementations don't exist yet. The tests define the contracts that implementations must satisfy:

- **`tests/test_trend_fetcher.py`**: Validates trend detection API contract (Section 2.2.3 of `specs/technical.md`)
- **`tests/test_skills_interface.py`**: Validates skills interface contracts (from `skills/README.md`)

**Current Test Status**: 11 tests, all failing with `ModuleNotFoundError` (expected in TDD phase)

### Docker Development

The project includes a Dockerfile for consistent development environments:

```bash
# Build Docker image
docker build -t chimera-dev:latest .

# Run tests in container
docker run --rm -v "$(PWD):/app" -w /app chimera-dev:latest pytest tests/ -v

# Interactive shell in container
docker run --rm -it -v "$(PWD):/app" -w /app chimera-dev:latest /bin/bash
```

Or use Docker Compose:

```bash
docker-compose up -d
docker-compose exec chimera-dev /bin/bash
```

### Spec Check

The `spec-check` command verifies that code aligns with specifications:

- Checks specification files exist and are complete
- Validates API contracts match `specs/technical.md`
- Verifies skills interfaces match `skills/README.md`
- Reports implementation status

Run it with: `.\make.ps1 spec-check` or `make spec-check`

---

## CI/CD & AI Governance

### Continuous Integration

The project uses **GitHub Actions** for automated testing and validation on every push:

- **Test Execution**: Runs all tests in Docker container (matches local environment)
- **Spec Alignment Check**: Validates code matches specifications
- **Code Quality**: Linting and code quality checks
- **Artifact Upload**: Test results are uploaded as artifacts for analysis

**Workflow**: `.github/workflows/main.yml`

**Status**: Runs on all branches and pull requests. Test failures and spec-check failures block merges.

### AI Code Review (CodeRabbit)

**CodeRabbit** provides automated AI-powered code reviews on every pull request:

- **Spec Alignment**: Ensures implementations match `specs/technical.md` and `skills/README.md`
- **Security Checks**: Identifies vulnerabilities, hardcoded secrets, injection risks
- **Architecture Compliance**: Validates MCP-only interface, swarm patterns, OCC implementation
- **TDD Compliance**: Ensures tests exist and follow TDD patterns

**Configuration**: `.coderabbit.yaml`

**Status**: CodeRabbit reviews are **required** for all pull requests. Reviews must pass before merging.

### Review Process

1. **Create Pull Request** → CodeRabbit automatically reviews
2. **GitHub Actions runs** → Tests and spec-check execute
3. **Both must pass** → CodeRabbit approval + CI/CD success
4. **Merge allowed** → When all checks pass

### CI/CD Badges

The badges at the top of this README show:
- **CI/CD Pipeline**: Status of automated tests
- **CodeRabbit**: AI review status
- **Python**: Version requirement
- **License**: Current license status

---

## Author

**Name: Gemechis Worku**  
*February 2026*

---

## References

- Project Chimera Software Requirements Specification (2026 Edition)
- Andreessen Horowitz — *The Trillion Dollar AI Software Development Stack*
- OpenClaw and Moltbook ecosystem analysis
- Model Context Protocol (MCP) specification

---

## License

[To be determined]

---

*For detailed architectural decisions and research findings, see the [`research/`](research/) directory.*
