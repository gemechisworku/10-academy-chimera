# Backend Implementation

This directory contains the backend implementation for Project Chimera.

## Structure

### `services/`
Core business logic services organized by domain:
- **`planner/`**: Goal decomposition, task DAG creation, dynamic replanning
- **`worker/`**: Stateless task executors for content generation, posting, engagement
- **`judge/`**: Quality validation, policy enforcement, HITL routing, OCC commit control
- **`globalstate/`**: Versioned state management with OCC
- **`dashboard/`**: Dashboard API endpoints for fleet monitoring and HITL queue
- **`wallet/`**: Non-custodial wallet management and on-chain transactions
- **`campaign/`**: Campaign composition and management
- **`memory/`**: Hierarchical memory retrieval (episodic/semantic)
- **`orchestrator/`**: Central orchestrator for fleet management

### `api/`
REST API layer:
- **`routes/`**: API route handlers (Planner, Worker, Judge, Dashboard, Wallet, Campaign APIs)
- **`middleware/`**: Authentication, rate limiting, error handling middleware

### `database/`
Data persistence layer:
- **`models/`**: Pydantic models and SQLAlchemy ORM models
- **`migrations/`**: Database migration scripts (Alembic)
- **`repositories/`**: Data access layer (repository pattern)

### `mcp/`
Model Context Protocol integration:
- **`clients/`**: MCP client implementations for external services
- **`integration/`**: MCP server integration and tool routing

### `core/`
Core utilities and configuration:
- **`config/`**: Application configuration management
- **`exceptions/`**: Custom exception classes
- **`utils/`**: Shared utility functions

### `storage/`
Object storage integration:
- **`object_storage/`**: S3/GCS handlers for media blob storage

### `queues/`
Queue management:
- Redis queue handlers for task_queue, review_queue, hitl_queue

## API Endpoints

See [`specs/technical.md`](../specs/technical.md) for complete API contracts:
- Planner API (`/planner/*`)
- Worker API (`/worker/*`)
- Judge API (`/judge/*`)
- GlobalState API (`/globalstate/*`)
- Dashboard API (`/dashboard/*`)
- Wallet Management API (`/wallet/*`)
- Campaign Composer API (`/campaign/*`)
- MCP Resource API (`/mcp/resources/*`)

## Database Schema

See [`specs/technical.md` Section 3](../specs/technical.md#3-database-schema-erd) for complete database schema definitions.

## Implementation Status

This directory structure is ready for implementation. All services should follow the specifications defined in:
- [`specs/technical.md`](../specs/technical.md) - API contracts and database schemas
- [`specs/functional.md`](../specs/functional.md) - User stories and acceptance criteria
- [`specs/_meta.md`](../specs/_meta.md) - Architectural principles and constraints

