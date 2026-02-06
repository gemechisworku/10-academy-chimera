# Frontend Implementation

This directory contains the frontend implementation for Project Chimera dashboard and HITL interfaces.

## Structure

### `pages/`
Main application pages:
- **`dashboard/`**: Main dashboard landing page
- **`hitl-queue/`**: Human-in-the-Loop review queue interface
- **`fleet-status/`**: Fleet monitoring and health dashboard
- **`cost-metrics/`**: Cost tracking and budget management
- **`policy-management/`**: Policy editor and version management
- **`campaign-composer/`**: Natural language campaign creation interface

### `components/`
Reusable UI components:
- **`common/`**: Shared components (buttons, forms, modals, etc.)
- **`hitl/`**: HITL-specific components (approval cards, edit interface)
- **`fleet/`**: Fleet monitoring components (agent cards, status indicators)
- **`campaign/`**: Campaign management components (task tree visualization)

### `services/`
API and external service clients:
- **`api/`**: REST API client for backend services
- **`mcp/`**: MCP client integration (if needed for frontend)

### `state/`
State management:
- **`stores/`**: State stores (Redux, Zustand, or similar)

### `utils/`
Frontend utilities:
- Helper functions, formatters, validators

### `assets/`
Static assets:
- Images, icons, fonts, etc.

## Features

### Human Moderator Interface
- HITL queue access and filtering (H-001, H-002, H-003, H-005)
- Content approval/rejection/edit workflows
- Risk-based filtering

### System Operator Interface
- Fleet monitoring (S-001)
- Policy management (S-002)
- Cost tracking (S-003)
- Audit trail access (S-004)
- Agent lifecycle management (S-005)
- Campaign composer (S-006)

## API Integration

The frontend consumes the Dashboard API endpoints defined in [`specs/technical.md` Section 2.5](../specs/technical.md#25-dashboard-api):
- `GET /dashboard/hitl-queue`
- `POST /dashboard/hitl-queue/{review_id}/approve`
- `POST /dashboard/hitl-queue/{review_id}/reject`
- `POST /dashboard/hitl-queue/{review_id}/edit`
- `GET /dashboard/fleet-status`
- `GET /dashboard/cost-metrics`

## Implementation Status

This directory structure is ready for implementation. All features should follow the user stories defined in:
- [`specs/functional.md`](../specs/functional.md) - User stories and acceptance criteria
- [`specs/technical.md`](../specs/technical.md) - API contracts

