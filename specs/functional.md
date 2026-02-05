# Project Chimera — Functional Specification

**Date:** 2026-02-04  
**Version:** 1.0  
**Status:** Active

---

## 1. Overview

This document defines user stories for Project Chimera from the perspective of each system actor: **Planner**, **Worker**, **Judge**, **Human Moderator**, and **System Operator**. Each story includes acceptance criteria and priority levels.

---

## 2. Actor Definitions

### 2.1 Planner
The Planner is an AI agent responsible for goal decomposition, task DAG creation, and dynamic replanning based on context shifts.

### 2.2 Worker
Workers are stateless, ephemeral AI executors that run atomic tasks in parallel, using MCP tools to generate content, render media, and interact with external platforms.

### 2.3 Judge
The Judge is an AI agent that validates Worker outputs against policy, persona, safety constraints, and quality criteria. It routes artifacts to auto-execute, HITL queue, or retry.

### 2.4 Human Moderator
Human operators who review HITL queue items, approve/reject/edit content, and manage policy exceptions.

### 2.5 System Operator
System administrators who monitor fleet health, manage policies, track costs, and audit system behavior.

---

## 3. Planner User Stories

### P-001: Goal Decomposition
**As a** Planner,  
**I need to** decompose high-level goals into atomic tasks,  
**So that** Workers can execute them in parallel without dependencies.

**Acceptance Criteria:**
- Planner receives goals from GlobalState with current `state_version`
- Planner creates a task DAG (Directed Acyclic Graph) with task dependencies
- Each task is atomic (can be executed independently by a Worker)
- Tasks are enqueued to `task_queue` with proper metadata (task_id, agent_id, task_type, dependencies)

**Priority:** Must-have

---

### P-002: Trend Fetching
**As a** Planner,  
**I need to** fetch current trends and news from external sources,  
**So that** I can create relevant content that aligns with current events.

**Acceptance Criteria:**
- Planner uses MCP server (mcp-server-news/search) to fetch trends
- Trends are filtered by agent persona and policy constraints
- Trend data is stored in episodic cache (Redis) for Worker access
- Planner incorporates trends into task context when creating content generation tasks

**Priority:** Must-have

---

### P-003: Dynamic Replanning
**As a** Planner,  
**I need to** detect when context has shifted (state_version advanced, goals changed, external events occurred),  
**So that** I can update the task DAG and cancel/requeue obsolete tasks.

**Acceptance Criteria:**
- Planner periodically checks GlobalState for state_version changes
- Planner compares current goals with active task DAG
- Planner cancels tasks that are no longer relevant
- Planner creates new tasks for updated goals
- Replanning decisions are logged for audit

**Priority:** Must-have

---

### P-004: Task Dependency Management
**As a** Planner,  
**I need to** manage task dependencies (e.g., video render depends on script generation),  
**So that** Workers execute tasks in the correct order.

**Acceptance Criteria:**
- Task DAG includes dependency edges (task_A depends on task_B)
- Workers cannot claim tasks until dependencies are completed
- Planner tracks task completion and releases dependent tasks
- Circular dependencies are detected and prevented

**Priority:** Must-have

---

## 4. Worker User Stories

### W-001: Content Generation
**As a** Worker,  
**I need to** generate text content (posts, replies, captions) based on task specifications,  
**So that** agents can publish engaging content to social platforms.

**Acceptance Criteria:**
- Worker receives atomic task from `task_queue`
- Worker uses agent persona (from AGENTS.md/SOUL.md) to generate content
- Generated content includes `confidence_score`, `risk_tags`, and `disclosure_level`
- Content is pushed to `review_queue` with full metadata

**Priority:** Must-have

---

### W-002: Image Generation
**As a** Worker,  
**I need to** generate images using MCP image generation tools (ideogram/midjourney),  
**So that** agents can create visual content for posts.

**Acceptance Criteria:**
- Worker calls MCP tool (mcp-server-ideogram/midjourney) with prompt and parameters
- Generated image is uploaded to object storage (S3/GCS)
- Image metadata (URL, dimensions, tool_provenance, cost) is stored in PostgreSQL
- Image asset is linked to task and pushed to `review_queue`

**Priority:** Must-have

---

### W-003: Video Rendering
**As a** Worker,  
**I need to** render videos using MCP video generation tools (runway/luma),  
**So that** agents can create video content for platforms like TikTok and Instagram Reels.

**Acceptance Criteria:**
- Worker calls MCP tool (mcp-server-runway/luma) with script, style, and tier parameters
- Video rendering job is tracked (status: pending/rendering/complete/failed)
- Rendered video is uploaded to object storage
- Video metadata (URL, duration, resolution, tool_provenance, cost, tier) is stored in PostgreSQL
- Video asset is linked to task and pushed to `review_queue`

**Priority:** Must-have

---

### W-004: Platform Posting
**As a** Worker,  
**I need to** post content to social platforms (Twitter, Instagram) using MCP tools,  
**So that** agents can publish content and engage with audiences.

**Acceptance Criteria:**
- Worker receives approved artifact (text/image/video) from Judge
- Worker calls MCP tool (mcp-server-twitter or mcp-server-instagram) with content and metadata
- Platform response (post_id, URL, timestamp) is stored in PostgreSQL
- Post status is updated (scheduled/published/failed)
- Cost event is emitted if posting incurs fees

**Priority:** Must-have

---

### W-005: Engagement Replies
**As a** Worker,  
**I need to** generate and post replies to comments/mentions on social platforms,  
**So that** agents can maintain active engagement with their audience.

**Acceptance Criteria:**
- Worker fetches new mentions/comments via MCP tool
- Worker generates contextually appropriate replies using agent persona
- Replies are validated by Judge before posting
- Reply metadata (original_post_id, reply_text, platform_id) is stored

**Priority:** Must-have

---

### W-006: Idempotent Execution
**As a** Worker,  
**I need to** execute tasks idempotently (safe to retry),  
**So that** OCC failures and retries don't cause duplicate effects.

**Acceptance Criteria:**
- Worker checks if task has already been completed (via task_id lookup)
- Worker uses idempotency keys for external API calls (via MCP)
- Worker can safely retry failed tasks without side effects
- Duplicate task execution is prevented

**Priority:** Must-have

---

## 5. Judge User Stories

### J-001: Quality Validation
**As a** Judge,  
**I need to** validate Worker outputs against quality criteria (grammar, coherence, relevance),  
**So that** only high-quality content is published.

**Acceptance Criteria:**
- Judge receives result from `review_queue`
- Judge evaluates content quality (grammar, coherence, relevance to persona)
- Judge assigns quality score (0.0 to 1.0)
- Low-quality content (< 0.70) is routed to retry with feedback

**Priority:** Must-have

---

### J-002: Policy Enforcement
**As a** Judge,  
**I need to** validate content against agent policy (AGENTS.md) and brand guidelines,  
**So that** agents never violate brand safety or policy constraints.

**Acceptance Criteria:**
- Judge loads current policy version from BoardKit repository
- Judge checks content against policy rules (allowed topics, prohibited language, disclosure requirements)
- Policy violations cause immediate rejection and routing to retry
- Policy version is recorded in audit log

**Priority:** Must-have

---

### J-003: Sensitive Topic Detection
**As a** Judge,  
**I need to** detect sensitive topics (politics, health, finance) in content,  
**So that** sensitive content is always routed to HITL for human review.

**Acceptance Criteria:**
- Judge analyzes content for sensitive topic keywords and context
- Judge updates `risk_tags` with detected topics (e.g., `["politics","health"]`)
- Content with sensitive topics is routed to HITL queue regardless of confidence score
- Sensitive topic detection is logged for audit

**Priority:** Must-have

---

### J-004: HITL Routing
**As a** Judge,  
**I need to** route artifacts to appropriate destinations (auto-execute, HITL queue, retry) based on confidence and risk,  
**So that** the system maintains safety while maximizing autonomy.

**Acceptance Criteria:**
- Judge evaluates `confidence_score` and `risk_tags` from Worker output
- Routing logic:
  - `confidence > 0.90` AND `not_sensitive` → auto-execute
  - `0.70 <= confidence <= 0.90` OR `sensitive` → HITL queue
  - `confidence < 0.70` OR `policy_fail` → retry
- Routing decision is logged with reasoning trace

**Priority:** Must-have

---

### J-005: OCC Commit Control
**As a** Judge,  
**I need to** validate state_version before committing results,  
**So that** ghost updates are prevented and state consistency is maintained.

**Acceptance Criteria:**
- Judge reads `input_state_version` from task metadata
- Judge checks current `GlobalState.state_version`
- If `state_version` has advanced, Judge rejects commit and requeues task for replanning
- If `state_version` matches, Judge commits result and advances `state_version`
- OCC failures are logged for monitoring

**Priority:** Must-have

---

### J-006: CFO Judge for Financial Transactions
**As a** CFO Judge,  
**I need to** validate all financial transactions (on-chain payments, ad spends) against budget limits,  
**So that** agents cannot exceed budget constraints.

**Acceptance Criteria:**
- CFO Judge receives financial transaction requests from Workers
- CFO Judge checks transaction amount against agent/campaign/global budget limits
- CFO Judge validates transaction purpose and recipient
- Approved transactions are signed and executed via MCP (mcp-server-coinbase)
- Budget updates are recorded in `cost_events` table

**Priority:** Must-have

---

## 6. Human Moderator User Stories

### H-001: HITL Queue Access
**As a** Human Moderator,  
**I need to** access the HITL review queue via dashboard,  
**So that** I can review content that requires human approval.

**Acceptance Criteria:**
- Dashboard displays HITL queue items (pending human review)
- Each item shows: artifact (text/image/video link), confidence score, risk tags, Judge reasoning trace
- Items can be filtered/sorted by: risk type, confidence, agent, timestamp
- Queue updates in real-time as new items arrive

**Priority:** Must-have

---

### H-002: Approve Content
**As a** Human Moderator,  
**I need to** approve HITL queue items,  
**So that** approved content can be published automatically.

**Acceptance Criteria:**
- Moderator clicks "Approve" on HITL queue item
- Approval action atomically updates GlobalState and releases held execution
- Approved content is enqueued for Worker to execute (post/publish)
- Approval decision is logged (reviewer_id, timestamp, artifact_hash, policy_version)

**Priority:** Must-have

---

### H-003: Reject Content
**As a** Human Moderator,  
**I need to** reject HITL queue items,  
**So that** inappropriate content is not published.

**Acceptance Criteria:**
- Moderator clicks "Reject" on HITL queue item
- Rejection action updates GlobalState and terminates workflow
- Rejection reason is recorded (optional text field)
- Rejection decision is logged for audit

**Priority:** Must-have

---

### H-004: Edit Content
**As a** Human Moderator,  
**I need to** edit HITL queue items before approval,  
**So that** I can fix minor issues without full rejection.

**Acceptance Criteria:**
- Moderator clicks "Edit" on HITL queue item
- Dashboard provides inline editing interface (text editor, image replacement, etc.)
- Edited content is saved as new artifact version
- Edited content goes through Judge validation again (with "human-edited" flag)
- Edit history is tracked (original → edited → approved)

**Priority:** Nice-to-have

---

### H-005: Filter by Risk Type
**As a** Human Moderator,  
**I need to** filter HITL queue by risk type (sensitive topic, low confidence, financial),  
**So that** I can prioritize high-risk items.

**Acceptance Criteria:**
- Dashboard provides filter dropdown: "All", "Sensitive Topics", "Low Confidence", "Financial"
- Filtering updates queue view in real-time
- Filter state is persisted in browser session

**Priority:** Must-have

---

## 7. System Operator User Stories

### S-001: Fleet Monitoring
**As a** System Operator,  
**I need to** monitor fleet health (agent status, queue depths, error rates),  
**So that** I can detect and resolve issues before they impact operations.

**Acceptance Criteria:**
- Dashboard displays fleet overview: total agents, active agents, idle agents, error agents
- Queue depths are shown (task_queue, review_queue, hitl_queue)
- Error rates and recent errors are displayed with stack traces
- Alerts are triggered for: queue depth > threshold, error rate > threshold, agent downtime

**Priority:** Must-have

---

### S-002: Policy Management
**As a** System Operator,  
**I need to** update agent policies (AGENTS.md, SOUL.md) and distribute them to agents,  
**So that** agent behavior can be adjusted without code changes.

**Acceptance Criteria:**
- Dashboard provides policy editor (or links to BoardKit repository)
- Policy changes require version bump and commit message
- Policy distribution is atomic (all agents receive new version simultaneously)
- Policy version history is maintained for rollback
- Agents reload policies on next planning cycle

**Priority:** Must-have

---

### S-003: Cost Tracking
**As a** System Operator,  
**I need to** track costs per agent, per campaign, and globally,  
**So that** I can monitor budget usage and optimize spending.

**Acceptance Criteria:**
- Dashboard displays cost metrics: total cost, cost per agent, cost per campaign, cost per engagement
- Cost breakdown by category: inference, generation, posting, transactions
- Cost trends over time (daily/weekly/monthly)
- Budget alerts when approaching limits

**Priority:** Must-have

---

### S-004: Audit Trail Access
**As a** System Operator,  
**I need to** access audit trails for all approval decisions, policy changes, and state commits,  
**So that** I can debug issues and ensure compliance.

**Acceptance Criteria:**
- Dashboard provides audit log viewer with filters (date range, agent, action type)
- Audit logs include: timestamp, actor, action, artifact_hash, policy_version, reasoning_trace
- Audit logs are immutable and cannot be deleted
- Export functionality for compliance reporting

**Priority:** Must-have

---

### S-005: Agent Lifecycle Management
**As a** System Operator,  
**I need to** create, update, pause, and delete agents,  
**So that** I can manage the fleet dynamically.

**Acceptance Criteria:**
- Dashboard provides agent creation form (agent_id, persona_config, initial_goals)
- Agents can be paused (stops processing new tasks) or deleted (removes from fleet)
- Agent updates (persona changes, goal updates) are versioned
- Agent lifecycle events are logged for audit

**Priority:** Must-have

---

## 8. Cross-Cutting Stories

### CC-001: MCP Tool Access
**As a** Planner/Worker/Judge,  
**I need to** access external capabilities via MCP tools,  
**So that** I can interact with platforms and services without direct API dependencies.

**Acceptance Criteria:**
- MCP Host/Client is embedded in agent runtime
- MCP servers are discoverable and registered (mcp-server-twitter, mcp-server-instagram, etc.)
- Tool calls are logged with request/response payloads
- Rate limiting and dry-run modes are enforced via MCP layer

**Priority:** Must-have

---

### CC-002: State Version Management
**As a** Planner/Worker/Judge,  
**I need to** read and commit state with version checks,  
**So that** OCC prevents ghost updates and maintains consistency.

**Acceptance Criteria:**
- GlobalState exposes `state_version` (monotonically increasing integer)
- All state reads include `state_version` snapshot
- All state commits include `input_state_version` and `output_state_version`
- OCC validation rejects commits if `state_version` has advanced

**Priority:** Must-have

---

## 9. Priority Summary

### Must-Have (MVP)
- All Planner stories (P-001 through P-004)
- All Worker stories (W-001 through W-006)
- All Judge stories (J-001 through J-006)
- HITL queue access, approve, reject, filter (H-001, H-002, H-003, H-005)
- Fleet monitoring, policy management, cost tracking, audit access (S-001 through S-004)
- Cross-cutting stories (CC-001, CC-002)

### Nice-to-Have (Future)
- Edit content (H-004)
- Advanced analytics dashboards
- Real-time collaboration features

---

**End of Functional Specification**

