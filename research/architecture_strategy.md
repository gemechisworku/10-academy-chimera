flowchart TB
  %% Control Plane
  OP["Human Super-Orchestrator"] --> DASH["Orchestrator Dashboard / Mission Control"]
  DASH --> ORCH["Central Orchestrator (Hub)<br/>GlobalState + Policies + Multi-tenancy"]

  %% Swarm Core
  ORCH --> PL["Planner Service<br/>Builds/updates Task DAG"]
  PL --> TQ[("Task Queue<br/>Redis")]
  TQ --> WK["Worker Pool (N)<br/>Stateless Executors"]
  WK --> RQ[("Review Queue<br/>Redis")]
  RQ --> JD["Judge Service<br/>QA + Policy + HITL routing<br/>OCC commit gate"]
  JD -->|commit / update| ORCH
  JD -->|retry / replan| PL
  JD -->|escalate| HITL["HITL Review Queue<br/>Human Moderators"]
  HITL -->|approve/reject| ORCH

  %% MCP Boundary
  subgraph MCP["MCP Integration Layer (Universal External Interface)"]
    HOST["MCP Host / Client<br/>(inside runtime)"]
    TW["mcp-server-twitter<br/>Tools/Resources"]
    IG["mcp-server-instagram<br/>Tools/Resources"]
    WV["mcp-server-web<br/>Tools/Resources"]
    IMG["mcp-server-ideogram/midjourney<br/>Generation Tools"]
    VID["mcp-server-runway/luma<br/>Generation Tools"]
    CB["mcp-server-coinbase<br/>AgentKit Tools"]
  end

  %% Tool usage
  WK --> HOST
  HOST --> TW
  HOST --> IG
  HOST --> WV
  HOST --> IMG
  HOST --> VID
  HOST --> CB