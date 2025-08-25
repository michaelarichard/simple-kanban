# Product Definition - Simple Kanban Board

## Core Problem
Need a simple, efficient way to track project work and task progress without vendor lock-in or licensing concerns.

## Solution
Web-based kanban board with drag-and-drop functionality that you fully own and control.

## Target Users
- Individual developers and small teams
- Users who want to avoid vendor dependency risk
- Teams needing customizable workflow tools

## Success Metrics
- Tasks can be created, moved, and completed intuitively
- Board state persists between sessions
- Fast, responsive interface
- Easy to modify and customize for specific workflows

## Initial Scope
- Three columns: To Do, In Progress, Done
- Create/edit/delete tasks
- Drag-and-drop between columns
- Task persistence (SQLite database)
- Simple, clean UI
- Single container deployment

## Constraints
- Containerized deployment following security patterns
- Single-user initially (multi-user expansion later)
- Web-based (no mobile app needed initially)
- Self-contained with no external dependencies

## Key Requirements from User
- **Full Ownership**: No licensing or vendor control issues
- **Customizable**: Easy to modify for specific workflows
- **Self-Hosted**: Complete control over data and deployment
- **Simple**: Focus on core kanban functionality without bloat
