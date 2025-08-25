# Architecture Decision - Simple Kanban Board

## Final Architecture: PostgreSQL + Redis (Option 2 Enhanced)

Based on requirements for **API integration** and **story planning workflows**, we're selecting the PostgreSQL + Redis pattern.

## Why PostgreSQL Over SQLite

### API and Integration Requirements
- **Complex Queries**: Story planning needs filtering, sorting, aggregation
- **Concurrent Access**: Multiple API clients and web users simultaneously
- **Data Relationships**: Projects, epics, stories, tasks with foreign keys
- **JSON Support**: PostgreSQL's JSONB for flexible metadata storage
- **Full-Text Search**: Built-in search for story content and descriptions
- **Transactions**: ACID compliance for complex workflow operations

### Future Story Planning Features
- **Multi-Project Support**: Different kanban boards per project
- **User Stories Integration**: Link tasks to user stories and epics
- **Time Tracking**: Story points, estimates, actual time
- **Reporting**: Velocity charts, burndown, cycle time analytics
- **Workflow Automation**: State transitions, notifications, integrations

## Enhanced Architecture

```
┌─────────────────┐    ┌─────────────────┐
│   Web UI        │    │   API Clients   │
│  (React/Vue)    │    │ (CLI, Scripts,  │
│                 │    │  Other Tools)   │
└─────────────────┘    └─────────────────┘
         │                       │
         └───────────┬───────────┘
                     │
┌─────────────────────────────────────────┐
│           FastAPI Backend               │
│  ┌─────────────┐ ┌─────────────────────┐│
│  │   Web API   │ │   Story Planning    ││
│  │ (Kanban)    │ │      API            ││
│  └─────────────┘ └─────────────────────┘│
│  ┌─────────────────────────────────────┐│
│  │     Swagger/OpenAPI Docs            ││
│  │   /docs (Interactive)               ││
│  │   /redoc (Alternative)              ││
│  │   /openapi.json (Schema)            ││
│  └─────────────────────────────────────┘│
└─────────────────────────────────────────┘
    │                           │
┌─────────┐                 ┌─────────┐
│ Redis   │                 │PostgreSQL│
│(Cache + │                 │(Primary  │
│Sessions)│                 │ Data)    │
└─────────┘                 └─────────┘
```

## API Documentation Strategy

### Swagger/OpenAPI Integration
- **FastAPI Auto-Generation**: Automatic OpenAPI 3.0 schema generation
- **Interactive Docs**: `/docs` endpoint with Swagger UI for testing
- **Alternative Docs**: `/redoc` endpoint with ReDoc interface
- **Schema Export**: `/openapi.json` for external tool integration
- **Type Safety**: Pydantic models ensure schema accuracy

## Data Model for API Integration

### Core Entities
```sql
-- Projects (multiple kanban boards)
CREATE TABLE projects (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Columns (To Do, In Progress, Done, etc.)
CREATE TABLE columns (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID REFERENCES projects(id),
    name VARCHAR(100) NOT NULL,
    position INTEGER NOT NULL,
    color VARCHAR(7) DEFAULT '#gray'
);

-- Tasks/Cards
CREATE TABLE tasks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID REFERENCES projects(id),
    column_id UUID REFERENCES columns(id),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    position INTEGER NOT NULL,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Story Planning Extensions
CREATE TABLE epics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID REFERENCES projects(id),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    status VARCHAR(50) DEFAULT 'active'
);

CREATE TABLE user_stories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    epic_id UUID REFERENCES epics(id),
    project_id UUID REFERENCES projects(id),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    acceptance_criteria TEXT[],
    story_points INTEGER,
    priority VARCHAR(20) DEFAULT 'medium'
);

-- Link tasks to user stories
ALTER TABLE tasks ADD COLUMN user_story_id UUID REFERENCES user_stories(id);
```

## Comprehensive API Structure

### Kanban Board API
```
GET    /api/projects                    # List all projects
POST   /api/projects                    # Create new project
GET    /api/projects/{id}               # Get project details
PUT    /api/projects/{id}               # Update project
DELETE /api/projects/{id}               # Delete project

GET    /api/projects/{id}/board         # Get full kanban board
GET    /api/projects/{id}/columns       # Get columns
POST   /api/projects/{id}/columns       # Create column
PUT    /api/columns/{id}                # Update column
DELETE /api/columns/{id}                # Delete column

GET    /api/projects/{id}/tasks         # Get all tasks
POST   /api/projects/{id}/tasks         # Create task
GET    /api/tasks/{id}                  # Get task details
PUT    /api/tasks/{id}                  # Update task
DELETE /api/tasks/{id}                  # Delete task
PUT    /api/tasks/{id}/move             # Move task to different column
```

### Story Planning API
```
GET    /api/projects/{id}/epics         # List epics
POST   /api/projects/{id}/epics         # Create epic
GET    /api/epics/{id}                  # Get epic details
PUT    /api/epics/{id}                  # Update epic
DELETE /api/epics/{id}                  # Delete epic

GET    /api/epics/{id}/stories          # List user stories in epic
POST   /api/epics/{id}/stories          # Create user story
GET    /api/stories/{id}                # Get story details
PUT    /api/stories/{id}                # Update story
DELETE /api/stories/{id}                # Delete story

GET    /api/stories/{id}/tasks          # Get tasks for story
POST   /api/stories/{id}/tasks          # Create task from story
```

### Analytics & Reporting API
```
GET    /api/projects/{id}/metrics       # Project metrics
GET    /api/projects/{id}/velocity      # Velocity chart data
GET    /api/projects/{id}/burndown      # Burndown chart data
GET    /api/projects/{id}/cycle-time    # Cycle time analytics
```

### Search & Filter API
```
GET    /api/search/tasks?q={query}      # Full-text search tasks
GET    /api/search/stories?q={query}    # Search user stories
GET    /api/tasks?filter={json}         # Advanced filtering
GET    /api/stories?filter={json}       # Filter stories
```

## Integration Benefits

### CLI Tool Integration
```bash
# Example CLI commands enabled by API
kanban create-project "My Project"
kanban add-task "Fix bug" --project="My Project" --column="To Do"
kanban move-task 123 --to="In Progress"
kanban create-story "User login" --epic="Authentication"
kanban link-task 123 --story=456
```

### Automation Scripts
```python
# Example Python integration
import requests

# Create tasks from user stories
stories = requests.get('/api/stories?status=ready').json()
for story in stories:
    requests.post('/api/tasks', json={
        'title': f"Implement: {story['title']}",
        'user_story_id': story['id'],
        'column_id': 'todo_column_id'
    })
```

### Workflow Integration
- **GitHub Issues**: Sync tasks with GitHub issues
- **Jira Integration**: Import/export user stories
- **Time Tracking**: Connect with time tracking tools
- **Notifications**: Slack/Discord webhooks for task updates

## Data Persistence Strategy

Following stormpath pattern:
- **PostgreSQL**: Primary data with volume mounts (`/var/lib/postgresql/data`)
- **Redis**: Session storage, real-time updates, API caching
- **Backup**: PostgreSQL dumps + Redis persistence
- **High Availability**: PostgreSQL replication for production

### FastAPI Implementation Details

```python
from fastapi import FastAPI
from fastapi.openapi.utils import get_openapi

app = FastAPI(
    title="Simple Kanban API",
    description="Self-hosted kanban board with story planning integration",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
    openapi_url="/openapi.json"
)

def custom_openapi():
    if app.openapi_schema:
        return app.openapi_schema
    openapi_schema = get_openapi(
        title="Simple Kanban API",
        version="1.0.0",
        description="API for kanban board management and story planning",
        routes=app.routes,
    )
    openapi_schema["info"]["x-logo"] = {
        "url": "/static/logo.png"
    }
    app.openapi_schema = openapi_schema
    return app.openapi_schema

app.openapi = custom_openapi
```

### Pydantic Models for Schema Generation

```python
from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime
from uuid import UUID

class ProjectCreate(BaseModel):
    name: str = Field(..., description="Project name")
    description: Optional[str] = Field(None, description="Project description")

class Project(BaseModel):
    id: UUID
    name: str
    description: Optional[str]
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True

class TaskCreate(BaseModel):
    title: str = Field(..., description="Task title")
    description: Optional[str] = Field(None, description="Task description")
    column_id: UUID = Field(..., description="Column ID where task belongs")
    user_story_id: Optional[UUID] = Field(None, description="Linked user story")
    metadata: Optional[dict] = Field(default_factory=dict)

class Task(BaseModel):
    id: UUID
    project_id: UUID
    column_id: UUID
    title: str
    description: Optional[str]
    position: int
    metadata: dict
    user_story_id: Optional[UUID]
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True
```

This architecture provides the robust foundation needed for comprehensive story planning and API integration while maintaining the ownership and control you require.
