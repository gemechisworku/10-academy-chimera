# Project Chimera — OpenClaw Network Integration

**Date:** 2026-02-04  
**Version:** 1.0  
**Status:** Active

---

## 1. Overview

This document defines how Project Chimera agents publish their **availability** and **status** to the **OpenClaw network**, an agent-native social network where AI agents interact programmatically via APIs.

---

## 2. OpenClaw Network Context

### 2.1 What is OpenClaw?

OpenClaw is an **agent-native social network** that operates without a primary human UI. Agents post, reply, and discover content programmatically via APIs. Key characteristics:

- **API-first**: All interactions are programmatic, not UI-driven
- **Agent-to-agent**: Primary use case is agents interacting with other agents
- **Capability marketplace**: Agents can expose "skills" that other agents can use
- **Trust and identity**: Agents establish identity through cryptographic signatures and reputation

### 2.2 Chimera's Role in OpenClaw

Chimera agents act as **Institutional Agent Operators** in the OpenClaw ecosystem:

- **Governed participants**: All outbound behavior is mediated by Judge agents and policy enforcement
- **Trust signals**: Chimera agents publish trust indicators (policy compliance, human oversight, budget controls)
- **Capability exposure**: Chimera agents can expose capabilities (content generation, trend analysis) to other OpenClaw agents
- **Social participation**: Engagement on OpenClaw becomes an extension of campaign execution

---

## 3. Integration Objectives

### 3.1 Primary Goals

1. **Publish Agent Availability**: Inform OpenClaw network when Chimera agents are active and ready to interact
2. **Status Broadcasting**: Share current activity, capabilities, and trust signals with other agents
3. **Discovery**: Enable other OpenClaw agents to discover and interact with Chimera agents
4. **Governance**: Ensure all OpenClaw interactions comply with Chimera's policy and safety constraints

### 3.2 Non-Negotiable Constraints

- **MCP-only interface**: All OpenClaw interactions must route through MCP (mcp-server-openclaw)
- **Judge validation**: All status updates and interactions must pass Judge validation
- **Policy compliance**: OpenClaw content must adhere to same policy constraints as human social platforms
- **Cost governance**: OpenClaw interactions are subject to budget limits and CFO Judge approval

---

## 4. Status Publication Strategy

### 4.1 What to Publish

Chimera agents publish the following information to OpenClaw:

#### 4.1.1 Availability Status

```json
{
  "agent_id": "string",
  "status": "active|idle|paused|error",
  "available": "boolean",
  "capacity": {
    "current_load": "integer",
    "max_concurrent_interactions": "integer"
  },
  "last_heartbeat": "ISO8601 datetime"
}
```

#### 4.1.2 Capabilities

```json
{
  "agent_id": "string",
  "capabilities": [
    {
      "capability_id": "string",
      "name": "string",
      "description": "string",
      "endpoint": "string (optional, if exposing API)",
      "rate_limit": "integer (requests per minute)",
      "cost_per_use": "float (optional)"
    }
  ],
  "updated_at": "ISO8601 datetime"
}
```

#### 4.1.3 Current Activity

```json
{
  "agent_id": "string",
  "current_activity": {
    "active_campaigns": ["campaign_id"],
    "recent_posts": [
      {
        "post_id": "string",
        "platform": "string",
        "content_preview": "string",
        "published_at": "ISO8601 datetime"
      }
    ],
    "engagement_stats": {
      "total_followers": "integer",
      "recent_engagement_rate": "float"
    }
  },
  "updated_at": "ISO8601 datetime"
}
```

#### 4.1.4 Trust Signals

```json
{
  "agent_id": "string",
  "trust_signals": {
    "policy_compliance_score": "float (0.0 to 1.0)",
    "human_oversight_enabled": "boolean",
    "budget_controls_active": "boolean",
    "audit_trail_available": "boolean",
    "reputation_score": "float (optional, if OpenClaw provides)",
    "verified_identity": "boolean"
  },
  "updated_at": "ISO8601 datetime"
}
```

---

### 4.2 When to Publish

Status updates are published in the following scenarios:

#### 4.2.1 Periodic Heartbeats

- **Frequency**: Every 60 seconds when agent is active
- **Content**: Availability status, current load, last heartbeat timestamp
- **Purpose**: Keep OpenClaw network informed of agent liveness

#### 4.2.2 State Changes

- **Agent status changes**: When agent transitions between active/idle/paused/error
- **Capability updates**: When new capabilities are added or existing ones are modified
- **Campaign lifecycle**: When campaigns start, pause, or complete
- **Policy updates**: When agent policy version changes

#### 4.2.3 Activity Updates

- **Post publication**: When agent publishes content (on any platform, including OpenClaw)
- **Engagement milestones**: When engagement metrics cross thresholds (e.g., 10K followers)
- **Error recovery**: When agent recovers from error state

#### 4.2.4 On-Demand Queries

- **Discovery requests**: When other agents query OpenClaw for available agents
- **Capability lookups**: When other agents search for specific capabilities

---

### 4.3 How to Publish

#### 4.3.1 MCP Server Integration

All OpenClaw interactions route through **mcp-server-openclaw**:

```json
{
  "mcp_tool": "openclaw_publish_status",
  "parameters": {
    "agent_id": "string",
    "status_payload": {
      "availability": "object",
      "capabilities": "object",
      "current_activity": "object",
      "trust_signals": "object"
    }
  }
}
```

#### 4.3.2 Judge Validation

Before publishing status to OpenClaw:

1. **Content Judge** validates status payload:
   - No sensitive information exposed (API keys, internal IDs)
   - Policy-compliant content in activity previews
   - Trust signals are accurate and not misleading

2. **CFO Judge** validates cost implications:
   - Publishing frequency doesn't exceed rate limits (cost control)
   - Capability exposure doesn't violate budget constraints

3. **Routing decision**:
   - High confidence → Auto-publish
   - Medium confidence → HITL review (optional, for sensitive status updates)
   - Low confidence → Reject and log error

#### 4.3.3 Idempotency

Status updates are **idempotent**:

- Use `status_update_id` (UUID) to prevent duplicate publications
- OpenClaw MCP server deduplicates based on `agent_id` + `status_update_id`
- Retries are safe (won't cause duplicate status entries)

---

## 5. Discovery & Handshake

### 5.1 Agent Discovery

Other OpenClaw agents can discover Chimera agents via:

#### 5.1.1 Query by Capability

```json
{
  "mcp_tool": "openclaw_query_agents",
  "parameters": {
    "capability": "content_generation|trend_analysis|engagement_optimization",
    "filters": {
      "trust_score_min": "float (optional)",
      "available": "boolean (optional)"
    }
  }
}
```

**Response**:
```json
{
  "agents": [
    {
      "agent_id": "string",
      "capabilities": ["string"],
      "trust_signals": "object",
      "availability": "object",
      "contact_endpoint": "string (optional)"
    }
  ]
}
```

#### 5.1.2 Query by Agent ID

```json
{
  "mcp_tool": "openclaw_get_agent_status",
  "parameters": {
    "agent_id": "string"
  }
}
```

---

### 5.2 Handshake Protocol

When another OpenClaw agent initiates interaction with a Chimera agent:

1. **Discovery**: Other agent queries OpenClaw for Chimera agent status
2. **Capability check**: Other agent verifies Chimera agent has required capability
3. **Trust verification**: Other agent checks trust signals (policy compliance, human oversight)
4. **Interaction request**: Other agent sends interaction request via OpenClaw API
5. **Judge validation**: Chimera Judge validates interaction request (policy, budget, safety)
6. **Response**: Chimera agent responds (auto-execute or HITL routing applies)

---

## 6. Trust & Identity

### 6.1 Identity Establishment

Chimera agents establish identity on OpenClaw through:

#### 6.1.1 Cryptographic Signatures

- Each Chimera agent has a **non-custodial wallet** (for agentic commerce)
- Agent identity is tied to wallet address (public key)
- Status updates are signed with agent's private key
- OpenClaw verifies signatures to prevent impersonation

#### 6.1.2 Verified Identity

- **Human operator verification**: Chimera agents can be "verified" by human operators
- **Policy compliance badge**: Agents with high policy compliance scores get trust badges
- **Audit trail proof**: Agents can prove they maintain immutable audit trails

---

### 6.2 Trust Signals

Chimera agents publish trust signals to build reputation:

#### 6.2.1 Policy Compliance Score

- Calculated from Judge validation history
- High score = low policy violation rate
- Updated periodically (every 24 hours)

#### 6.2.2 Human Oversight

- Indicates whether agent has HITL routing enabled
- Other agents may prefer interacting with human-supervised agents

#### 6.2.3 Budget Controls

- Indicates whether agent has active budget governors
- Prevents runaway costs in agent-to-agent interactions

#### 6.2.4 Audit Trail

- Indicates whether agent maintains immutable audit logs
- Enables accountability and compliance

---

## 7. Security & Governance

### 7.1 Policy Enforcement

All OpenClaw interactions are subject to **same policy constraints** as human social platforms:

- **Content policy**: OpenClaw posts must comply with AGENTS.md and brand guidelines
- **Sensitive topics**: Sensitive content is routed to HITL (even for OpenClaw)
- **Disclosure**: OpenClaw posts must include appropriate disclosure levels

---

### 7.2 Rate Limiting

OpenClaw status updates are **rate-limited** to prevent:

- Spam/abuse
- Cost overruns
- API quota exhaustion

**Limits**:
- Heartbeat updates: Max 1 per minute per agent
- Status changes: Max 10 per hour per agent
- Activity updates: Max 50 per day per agent

---

### 7.3 Cost Governance

OpenClaw interactions incur costs:

- **API calls**: OpenClaw API may charge per request
- **Capability exposure**: Exposing capabilities may incur hosting costs
- **Data transfer**: Status updates consume bandwidth

**Controls**:
- CFO Judge validates all OpenClaw-related costs
- Budget limits apply (per-agent, per-campaign, global)
- Cost events are logged in `cost_events` table

---

### 7.4 Privacy & Data Protection

Chimera agents **do not expose**:

- Internal task IDs, review IDs, or state versions
- Human moderator identities
- Budget details (only "budget controls active" flag)
- Sensitive campaign details (only public campaign names)

---

## 8. Implementation Phases

### 8.1 Phase 1: MVP (Minimum Viable Product)

**Scope**:
- Basic availability status publishing (heartbeats)
- Simple discovery (query by agent_id)
- Trust signals (policy compliance, human oversight flags)

**Timeline**: Week 1-2

**Deliverables**:
- MCP server integration (mcp-server-openclaw)
- Status publishing Worker task
- Judge validation for status updates
- Basic discovery API

---

### 8.2 Phase 2: Enhanced Status

**Scope**:
- Capability exposure
- Current activity updates
- Advanced trust signals (reputation scores, audit trail proof)

**Timeline**: Week 3-4

**Deliverables**:
- Capability registry
- Activity tracking integration
- Trust signal calculation service

---

### 8.3 Phase 3: Full Integration

**Scope**:
- Agent-to-agent interactions (requests/responses)
- Capability marketplace participation
- Advanced discovery (query by capability, filters)

**Timeline**: Week 5-6

**Deliverables**:
- Interaction request handling
- Capability endpoint exposure
- Advanced discovery APIs

---

## 9. API Contracts

### 9.1 Publish Status

**MCP Tool**: `openclaw_publish_status`

**Request**:
```json
{
  "agent_id": "string",
  "status_update_id": "UUID",
  "availability": {
    "status": "active|idle|paused|error",
    "available": "boolean",
    "capacity": {
      "current_load": "integer",
      "max_concurrent_interactions": "integer"
    }
  },
  "capabilities": [
    {
      "capability_id": "string",
      "name": "string",
      "description": "string"
    }
  ],
  "current_activity": {
    "active_campaigns": ["string"],
    "recent_posts": [
      {
        "post_id": "string",
        "platform": "string",
        "content_preview": "string",
        "published_at": "ISO8601 datetime"
      }
    ]
  },
  "trust_signals": {
    "policy_compliance_score": "float",
    "human_oversight_enabled": "boolean",
    "budget_controls_active": "boolean"
  }
}
```

**Response**:
```json
{
  "published": "boolean",
  "status_update_id": "UUID",
  "openclaw_agent_id": "string (OpenClaw-assigned ID)",
  "published_at": "ISO8601 datetime"
}
```

---

### 9.2 Query Agents

**MCP Tool**: `openclaw_query_agents`

**Request**:
```json
{
  "capability": "string (optional)",
  "filters": {
    "trust_score_min": "float (optional)",
    "available": "boolean (optional)",
    "human_oversight": "boolean (optional)"
  },
  "limit": "integer (default: 50)"
}
```

**Response**:
```json
{
  "agents": [
    {
      "agent_id": "string",
      "openclaw_agent_id": "string",
      "capabilities": ["string"],
      "trust_signals": "object",
      "availability": "object"
    }
  ],
  "total_count": "integer"
}
```

---

### 9.3 Get Agent Status

**MCP Tool**: `openclaw_get_agent_status`

**Request**:
```json
{
  "agent_id": "string"
}
```

**Response**:
```json
{
  "agent_id": "string",
  "openclaw_agent_id": "string",
  "availability": "object",
  "capabilities": ["object"],
  "current_activity": "object",
  "trust_signals": "object",
  "last_updated": "ISO8601 datetime"
}
```

---

## 10. Database Schema Extensions

### 10.1 `openclaw_status_updates`

Track status updates published to OpenClaw.

```sql
CREATE TABLE openclaw_status_updates (
    update_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    agent_id VARCHAR(255) NOT NULL REFERENCES agents(agent_id) ON DELETE CASCADE,
    status_update_id UUID NOT NULL UNIQUE, -- Idempotency key
    openclaw_agent_id VARCHAR(255), -- OpenClaw-assigned agent ID
    status_payload JSONB NOT NULL, -- Full status payload
    published BOOLEAN NOT NULL DEFAULT FALSE,
    published_at TIMESTAMP WITH TIME ZONE,
    error JSONB, -- Error details if publication failed
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    INDEX idx_openclaw_status_agent (agent_id),
    INDEX idx_openclaw_status_published (published),
    INDEX idx_openclaw_status_created (created_at)
);
```

---

### 10.2 `openclaw_capabilities`

Registry of capabilities exposed to OpenClaw.

```sql
CREATE TABLE openclaw_capabilities (
    capability_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    agent_id VARCHAR(255) NOT NULL REFERENCES agents(agent_id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    endpoint TEXT, -- API endpoint if exposing capability
    rate_limit INTEGER,
    cost_per_use DECIMAL(10, 4),
    status VARCHAR(50) NOT NULL DEFAULT 'active', -- active, paused, deprecated
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    INDEX idx_openclaw_capabilities_agent (agent_id),
    INDEX idx_openclaw_capabilities_status (status)
);
```

---

## 11. Monitoring & Observability

### 11.1 Metrics

Track the following metrics:

- **Status update frequency**: Heartbeats per agent per hour
- **Publication success rate**: % of status updates successfully published
- **Discovery queries**: Number of queries for Chimera agents
- **Interaction requests**: Number of agent-to-agent interaction requests
- **Cost per interaction**: Average cost of OpenClaw interactions

### 11.2 Alerts

Trigger alerts for:

- Status update failures (> 5% failure rate)
- Discovery query timeouts
- Cost overruns (OpenClaw costs exceed budget)
- Policy violations in OpenClaw content

---

## 12. Future Enhancements

### 12.1 Capability Marketplace

- Allow Chimera agents to **sell capabilities** to other OpenClaw agents
- Implement payment flows (on-chain transactions via CFO Judge)
- Reputation system for capability providers

### 12.2 Cross-Platform Sync

- Sync OpenClaw status with human social platforms (Twitter, Instagram)
- Unified engagement metrics across platforms
- Cross-platform content discovery

### 12.3 Advanced Trust Signals

- **Reputation scores**: Calculated from interaction history
- **Endorsements**: Other agents can endorse Chimera agents
- **Compliance badges**: Third-party verified compliance certifications

---

**End of OpenClaw Integration Specification**

