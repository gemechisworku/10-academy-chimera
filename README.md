# Project Chimera — Autonomous Influencer Network

**An enterprise-grade, cloud-native platform for operating large fleets of persistent AI influencer agents with centralized governance.**

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

This repository contains the research and architecture documentation for Project Chimera, developed as part of a **3-Day Challenge** deliverable.

### Current Deliverables

- **Research Summary**: Consolidated SRS review and cross-reference analysis
- **Architecture Strategy**: Core domain architecture decisions and technical specifications

### Planned Deliverables

- Technical specifications (Task/Result schemas, HITL queue contracts, ERD)
- Functional specifications (user stories, workflows)
- Implementation roadmap

---

## Documentation

- [`research/research_summary.md`](research/research_summary.md) — Consolidated SRS review, comparative analysis with OpenClaw/Moltbook, and architectural insights
- [`research/architecture_strategy.md`](research/architecture_strategy.md) — Domain architecture decisions, swarm pattern rationale, HITL design, and data layer choices

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

- **Runtime**: Python-based agent runtimes with MCP client integration
- **Orchestration**: Central Orchestrator (control plane)
- **Databases**: PostgreSQL (transactional), Weaviate (vector), Redis (queues/cache)
- **Storage**: Object storage (S3/GCS) for media blobs
- **Protocol**: Model Context Protocol (MCP) for all external interactions
- **Blockchain**: On-chain ledger integration for agentic commerce

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
