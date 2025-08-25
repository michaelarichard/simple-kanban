# Product Research - Simple Kanban Board

## Existing Self-Hosted Kanban Solutions

### Analyzed Solutions
- **Wekan** - Open source, but MongoDB dependency, complex setup
- **Kanboard** - PHP-based, feature-heavy, dated UI
- **Focalboard** - Microsoft-owned, Go-based, good but corporate control
- **Planka** - React/Node.js, nice UI but limited customization
- **Taiga** - Full project management, overkill for simple kanban

### Key Problems with Existing Solutions
- **Licensing Risk**: Corporate acquisitions change terms (Trello → Atlassian)
- **Feature Bloat**: Most solutions become complex project management tools
- **Dependency Hell**: Heavy database requirements, complex deployments
- **Limited Customization**: Hard to modify for specific workflows
- **Maintenance Burden**: Updates break configurations, forced migrations

## Our Competitive Advantages

### Ownership & Control
- **True Ownership**: MIT/Apache license, no vendor lock-in
- **Self-Contained**: SQLite database, no external services required
- **Easily Customizable**: Clean codebase for workflow modifications
- **Security-First**: Non-root containers, following established patterns

### Technical Advantages
- **Containerized**: Single Docker image, no complex dependencies
- **Minimal & Fast**: Focus on core kanban functionality only
- **Modern Stack**: FastAPI backend, modern JavaScript frontend
- **Simple Deployment**: Single container with established security patterns

## Market Opportunity
- Developers want simple, hackable tools they can modify
- Teams need kanban without vendor dependency risk
- Self-hosted solutions often have poor UX - we can do better
- Container-first approach simplifies deployment and scaling

## Technical Approach Decision
- **Frontend**: Modern JavaScript (React/Vue) for responsive UI
- **Backend**: FastAPI (following our template) with SQLite
- **Deployment**: Single container with our established security patterns
- **Data**: Simple JSON API, easy to backup/migrate
- **Architecture**: Clean separation for easy customization
