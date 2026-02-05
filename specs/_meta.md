# Project Chimera — Meta Specification

**Date:** 2026-02-04  
**Version:** 1.0  
**Status:** Active

---

## 1. Project Vision

**Project Chimera (AiQEM Autonomous Influencer Network)** is an enterprise-grade, cloud-native platform designed to operate large fleets of persistent AI influencer agents with centralized governance. The system enables a single operator (or small team) to manage **1,000+ autonomous influencer agents** simultaneously, each capable of:

- Generating high-velocity content (text, images, videos)
- Engaging across multiple social platforms (Twitter/X, Instagram, TikTok)
- Participating in agent-native networks (OpenClaw, Moltbook)
- Conducting agentic commerce (on-chain transactions)
- Maintaining brand safety and policy compliance

Unlike consumer-grade AI assistants, Chimera enforces enterprise-level governance, safety, and economic controls while maximizing throughput and maintaining quality.

---

## 2. Core Architectural Principles

### 2.1 Hub-and-Spoke Topology

Chimera operates as a **fractal orchestration system**:

- **Hub (Central Orchestrator)**: Control plane managing global state, policy distribution, dashboards, and multi-tenancy
- **Spokes (Agent Runtimes)**: Individual agents with internal hierarchical swarms, operating autonomously at the edge

This architecture enables centralized oversight with strong autonomy at the edge, allowing the system to scale from a single operator to managing thousands of agents without linear increases in operational overhead.

### 2.2 Hierarchical Swarm Pattern (FastRender)

Each agent is not monolithic but dynamically instantiated as a **Planner–Worker–Judge swarm**:

- **Planner**: Owns goal decomposition, task DAG creation, and dynamic replanning
- **Worker Pool**: Stateless, ephemeral executors that run atomic tasks in parallel
- **Judge**: Enforces quality, policy compliance, safety constraints, OCC commit control, and HITL routing

This pattern optimizes for:
- **Throughput**: Parallel execution across stateless workers
- **Governance**: Mandatory quality and policy gates
- **Correctness**: Optimistic Concurrency Control (OCC) prevents ghost updates
- **Failure Isolation**: Worker failures don't cascade

### 2.3 MCP-Only External Interface

**All external interactions must route through Model Context Protocol (MCP) servers.**

- No direct SDK/API calls from Planner/Worker/Judge to social/video/image/news/chain providers
- External capabilities accessed via MCP Tools/Resources
- Enables centralized logging, rate limiting, dry-run modes, and fast provider swaps
- Provides platform volatility isolation (when APIs change, only MCP servers need updates)

### 2.4 Management-by-Exception

Human oversight is **routed by exception**, not constant supervision:

- **High confidence (> 0.90)**: Auto-approve and execute
- **Medium confidence (0.70 – 0.90)**: Asynchronous human approval (HITL queue)
- **Low confidence (< 0.70)**: Auto-retry with improved strategy
- **Sensitive topics**: Mandatory human review regardless of confidence

Humans approve **effects** (publishing actions, paid actions, financial transactions), not intermediate drafts.

---

## 3. Non-Negotiable Constraints

### 3.1 Platform Volatility Isolation

**Constraint**: All external platform interactions must go through MCP servers.

**Rationale**: Social media APIs, video generation services, and blockchain protocols change frequently. MCP abstraction allows the core system to remain stable while only MCP servers adapt to provider changes.

**Enforcement**: Code reviews and runtime checks must verify no direct API calls exist outside MCP boundaries.

### 3.2 Optimistic Concurrency Control (OCC)

**Constraint**: Every state commit must include `input_state_version` and `output_state_version` checks.

**Rationale**: With thousands of parallel workers, race conditions and "ghost updates" are inevitable without explicit versioning. OCC ensures state consistency at scale.

**Enforcement**: Judge service must reject commits if `GlobalState.state_version` has advanced since task creation.

### 3.3 Confidence Scoring Contract

**Constraint**: Every Worker output must include:
- `confidence_score: float` (0.0 to 1.0)
- `risk_tags: list[str]` (e.g., `["politics","health","finance"]`)
- `disclosure_level` for publishing actions (automated/assisted/none)

**Rationale**: Judge routing decisions depend on confidence and risk assessment. Without standardized metadata, HITL routing cannot function.

**Enforcement**: Schema validation (Pydantic) at Worker output boundaries.

### 3.4 Cost Governance

**Constraint**: All cost-incurring operations (video generation tiers, ad spends, on-chain transactions) must be:
- Tracked in `cost_events` table
- Subject to budget governors (per-agent, per-campaign, global)
- Routed through CFO Judge for approval (unless policy allows auto-approve for small spends)

**Rationale**: Runaway costs are a primary risk in autonomous agent systems. Explicit cost tracking and governors prevent budget overruns.

**Enforcement**: MCP servers must emit cost events; CFO Judge must validate against budget limits.

### 3.5 Auditability & Traceability

**Constraint**: For every approval decision, store:
- Reviewer ID and timestamp
- Exact artifact hash/content snapshot approved
- Policy version (from BoardKit/AGENTS.md)
- Judge reasoning trace (redacted as needed)

**Rationale**: Compliance, debugging, and future policy refinement require complete audit trails.

**Enforcement**: Database schema must support immutable audit logs.

---

## 4. Success Metrics

### 4.1 Throughput

- **Target**: Process 10,000+ tasks per hour across the fleet
- **Measurement**: Tasks completed per unit time, queue depth, worker utilization

### 4.2 Quality

- **Target**: < 5% auto-retry rate, < 1% policy violations
- **Measurement**: Judge rejection rates, HITL escalation rates, post-deletion rates

### 4.3 Safety

- **Target**: Zero unauthorized sensitive-topic posts, zero unauthorized financial transactions
- **Measurement**: Policy violation incidents, HITL catch rate for sensitive content

### 4.4 Cost Efficiency

- **Target**: Cost per engagement < $0.10, cost per post < $1.00
- **Measurement**: Cost events aggregated by campaign/agent, ROI per campaign

### 4.5 Operational Efficiency

- **Target**: < 1% of tasks require human intervention
- **Measurement**: HITL queue size, human approval time, auto-approval rate

---

## 5. Out of Scope (Phase 1)

The following capabilities are explicitly **deferred to future phases**:

- **Real-time video streaming**: Focus on pre-rendered content initially
- **Multi-language support**: English-only for MVP
- **Advanced analytics dashboards**: Basic fleet status and HITL queue only
- **Custom MCP server development**: Use existing MCP servers from ecosystem
- **On-chain governance**: Agentic commerce enabled, but governance voting deferred
- **Mobile applications**: Web dashboard only
- **Third-party integrations beyond MCP**: All external capabilities via MCP

---

## 6. Reference Documents

- [`research/architecture_strategy.md`](../research/architecture_strategy.md) — Core architectural decisions
- [`specs/functional.md`](functional.md) — User stories and acceptance criteria
- [`specs/technical.md`](technical.md) — API contracts and database schema
- [`specs/openclaw_integration.md`](openclaw_integration.md) — OpenClaw network integration plan

---

## 7. Governance Model

### 7.1 Policy-Driven Configuration

Agent behavior is governed by **spec-driven policy files**:

- **AGENTS.md**: Agent persona, goals, constraints, disclosure requirements
- **SOUL.md**: Personality traits, communication style, brand voice
- **BoardKit**: Policy versioning, approval workflows, compliance rules

Policy changes require versioning and audit trails.

### 7.2 Human-in-the-Loop (HITL) Routing

HITL is not a separate review team but a **routing outcome** of the Judge stage:

1. Worker generates artifact + confidence/risk metadata
2. Judge validates against policy, persona, safety constraints
3. Judge routes to: auto-execute, HITL queue, or retry
4. Human moderators review HITL queue items via dashboard
5. Approved items execute; rejected items terminate workflow

### 7.3 Multi-Judge Architecture

Judges are split by domain risk:

- **Content Judge**: Text/image/video governance, brand safety, sensitive topics
- **CFO Judge**: All financial transactions, cost approvals, budget enforcement

This separation allows specialized validation logic and independent scaling.

---

## 8. Technology Stack (Non-Negotiable)

### 8.1 Core Services

- **PostgreSQL**: Transactional metadata, lineage, governance, publishing state
- **Redis**: Episodic cache, task queues (task_queue, review_queue, hitl_queue)
- **Weaviate**: Vector memory / RAG for long-term agent memory
- **Object Storage (S3/GCS)**: Media blobs (renders, thumbnails, intermediates)
- **On-chain Ledger**: Agentic commerce (non-custodial wallets)

### 8.2 Agent Runtime

- **MCP Host/Client**: Embedded in agent runtime for external capability access
- **Planner/Worker/Judge Services**: Stateless services that scale horizontally
- **GlobalState Service**: Versioned state management with OCC

### 8.3 Control Plane

- **Central Orchestrator**: Global state, policy distribution, multi-tenancy
- **Dashboard**: Fleet monitoring, HITL review interface, policy management
- **Policy Repository**: Versioned AGENTS.md, SOUL.md, BoardKit files

---

## 9. Risk Mitigation

### 9.1 State Consistency

**Risk**: Ghost updates from concurrent workers  
**Mitigation**: OCC with state_version checks at Judge commit stage

### 9.2 Cost Overruns

**Risk**: Runaway inference/generation/posting costs  
**Mitigation**: Budget governors, CFO Judge, cost event tracking

### 9.3 Policy Violations

**Risk**: Agents post sensitive content or violate brand guidelines  
**Mitigation**: Content Judge, sensitive-topic filters, mandatory HITL for high-risk content

### 9.4 Platform API Changes

**Risk**: External APIs change, breaking agent capabilities  
**Mitigation**: MCP abstraction layer isolates platform volatility

### 9.5 Scale Bottlenecks

**Risk**: System cannot handle 1,000+ agents  
**Mitigation**: Stateless workers, horizontal scaling, partitioned databases, read replicas

---

## 10. Compliance & Security

### 10.1 Disclosure Requirements

All publishing actions must include appropriate disclosure levels:
- **Automated**: Clear indication content is AI-generated
- **Assisted**: Human-reviewed AI content
- **None**: Human-created content (rare in Chimera context)

### 10.2 Data Privacy

- Agent interactions logged for audit but not exposed to third parties
- User engagement data aggregated and anonymized
- Media assets stored in object storage with access controls

### 10.3 Financial Security

- Non-custodial wallets for agentic commerce
- CFO Judge must approve all on-chain transactions
- Transaction signing keys stored in secure key management

---

**End of Meta Specification**

