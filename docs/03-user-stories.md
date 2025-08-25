# User Stories - Simple Kanban Board

## Epic 1: Core Kanban Functionality

### US-001 (High Priority)
**As a user, I want to create tasks with title and description so I can track work items**
- **Acceptance Criteria:**
  - Task creation form with title (required), description (optional)
  - New tasks appear in "To Do" column by default
  - Form validation prevents empty titles
  - Tasks display title prominently, description on hover/click

### US-002 (High Priority)
**As a user, I want to drag tasks between columns (To Do, In Progress, Done) so I can update status visually**
- **Acceptance Criteria:**
  - Drag-and-drop works on desktop browsers
  - Touch gestures work on mobile devices
  - Visual feedback during drag (ghost image, drop zones)
  - Task position updates immediately
  - Changes persist to database

### US-003 (High Priority)
**As a user, I want tasks to persist between sessions so my work isn't lost**
- **Acceptance Criteria:**
  - Tasks saved to SQLite database
  - Board state restored on page reload
  - No data loss during browser crashes
  - Automatic save on any change

### US-004 (Medium Priority)
**As a user, I want to edit task details so I can update information as work progresses**
- **Acceptance Criteria:**
  - Click task to open edit modal
  - Modify title and description
  - Save/cancel options
  - Changes reflect immediately in UI

### US-005 (Medium Priority)
**As a user, I want to delete tasks so I can remove completed or cancelled items**
- **Acceptance Criteria:**
  - Delete button/option in task menu
  - Confirmation dialog to prevent accidents
  - Task removed from UI and database
  - No way to accidentally delete multiple tasks

## Epic 2: Self-Hosting & Control

### US-006 (High Priority)
**As a system admin, I want single-container deployment so I can run it anywhere without dependencies**
- **Acceptance Criteria:**
  - Single `docker run` command starts the application
  - No external database required
  - Runs on port 8000 by default
  - Data persists in mounted volume

### US-007 (High Priority)
**As a developer, I want to modify the UI/workflow so I can customize it for my team's needs**
- **Acceptance Criteria:**
  - Clean, well-documented code structure
  - Separate components for easy modification
  - CSS variables for easy theming
  - Clear API for adding new columns/features

### US-008 (Medium Priority)
**As a user, I want to export/import board data so I can backup and migrate between instances**
- **Acceptance Criteria:**
  - Export board as JSON file
  - Import JSON to restore board state
  - Validation of imported data
  - Clear error messages for invalid imports

### US-009 (Low Priority)
**As a system admin, I want configuration via environment variables so I can customize behavior without code changes**
- **Acceptance Criteria:**
  - Database path configurable
  - Port number configurable
  - Basic theming options via env vars
  - Documentation of all available options

## Epic 3: Performance & Security

### US-010 (High Priority)
**As a user, I want fast page loads and responsive interactions so the tool doesn't slow me down**
- **Acceptance Criteria:**
  - Initial page load under 2 seconds
  - Drag operations feel smooth (60fps)
  - API responses under 100ms
  - Minimal JavaScript bundle size

### US-011 (Medium Priority)
**As a system admin, I want the container to run as non-root so it follows security best practices**
- **Acceptance Criteria:**
  - Container runs as user 1000:1000
  - No privileged operations required
  - Read-only root filesystem where possible
  - Security context configured in Helm chart

### US-012 (Low Priority)
**As a user, I want keyboard shortcuts so I can work efficiently**
- **Acceptance Criteria:**
  - 'N' to create new task
  - Arrow keys to move between tasks
  - Enter to edit selected task
  - Delete key to remove selected task
  - Escape to cancel operations

## Story Prioritization

**Phase 1 (MVP):** US-001, US-002, US-003, US-006, US-010, US-011
**Phase 2 (Enhancement):** US-004, US-005, US-007, US-008
**Phase 3 (Polish):** US-009, US-012
