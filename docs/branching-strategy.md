# Branching Strategy - Simple Kanban Board

## Overview

This document outlines the branching strategy for exploring different development approaches while preserving the baseline planning and architecture.

## Branch Structure

### `main` - Active Development
- **Purpose**: Primary development branch for current implementation approach
- **Contains**: Latest working code and documentation
- **Deployment**: Used for production deployments
- **Protection**: Requires PR reviews for changes

### `planning-baseline` - Planning Preservation
- **Purpose**: Frozen snapshot of complete planning and architecture phase
- **Contains**: All planning documents, user stories, architecture decisions, observability design
- **Immutable**: Should not be modified to preserve baseline
- **Reference**: Use for comparing different development approaches

## Development Approach Branches

### Potential Development Styles

**`dev/tdd-approach`** - Test-Driven Development
- Start with comprehensive test suite
- Implement features to pass tests
- Focus on high test coverage from day one

**`dev/api-first`** - API-First Development
- Begin with OpenAPI specification
- Generate client/server stubs
- Build frontend against API contracts

**`dev/mvp-minimal`** - Minimal MVP Approach
- Implement only core kanban functionality
- Skip advanced features initially
- Focus on single-user, basic drag-and-drop

**`dev/full-stack`** - Full-Stack Parallel Development
- Develop frontend and backend simultaneously
- Use mock data during development
- Integrate components progressively

## Workflow Examples

### Starting a New Development Approach
```bash
# Create new development branch from planning baseline
git checkout planning-baseline
git checkout -b dev/tdd-approach

# Begin development with chosen methodology
# Make commits specific to that approach

# Push development branch
git push -u origin dev/tdd-approach
```

### Comparing Approaches
```bash
# View differences between approaches
git diff dev/tdd-approach dev/api-first

# Merge successful patterns back to main
git checkout main
git merge dev/tdd-approach
```

### Preserving Experiments
```bash
# Tag important milestones
git tag -a v0.1-tdd-experiment -m "TDD approach milestone"
git push origin v0.1-tdd-experiment

# Archive completed experiments
git checkout main
git branch -d dev/completed-experiment
```

## Branch Protection Rules

### `main` Branch
- Require PR reviews (1+ approvers)
- Require status checks to pass
- Require branches to be up to date
- Restrict force pushes

### `planning-baseline` Branch
- Require PR reviews (2+ approvers)
- Restrict force pushes
- Restrict deletions
- Only allow documentation updates

## Development Guidelines

### Commit Messages
Use conventional commit format:
```
feat: add user authentication
fix: resolve drag-and-drop bug
docs: update API documentation
test: add integration tests for tasks
refactor: simplify database queries
```

### PR Guidelines
- Reference planning documents when implementing features
- Include tests for new functionality
- Update documentation for API changes
- Link to relevant user stories or development stories

### Merge Strategy
- **Feature branches**: Squash and merge to keep clean history
- **Development approaches**: Merge commit to preserve experiment history
- **Hotfixes**: Fast-forward merge for urgent fixes

## Planning Baseline Contents

The `planning-baseline` branch preserves:

### Complete Planning Documentation
- Product definition and research
- User stories and acceptance criteria
- Architecture decisions and options
- Development story breakdown
- Feature planning and milestones

### Infrastructure Configuration
- Docker and Kubernetes configurations
- SOPS secrets management setup
- Observability and monitoring stack
- CI/CD pipeline definitions

### Development Workflows
- AI-powered development processes
- Code quality and security standards
- Testing and deployment procedures
- Team collaboration guidelines

## Benefits of This Strategy

### **Experimentation Safety**
- Try different development methodologies without losing baseline
- Compare approaches objectively
- Rollback to known-good state if needed

### **Learning Opportunities**
- Document lessons learned from each approach
- Build institutional knowledge about what works
- Create reusable patterns for future projects

### **Risk Mitigation**
- Preserve comprehensive planning investment
- Maintain multiple development paths
- Reduce risk of losing progress during experimentation

### **Team Collaboration**
- Clear reference point for all team members
- Consistent baseline for discussions
- Easy onboarding with preserved context

## Usage Recommendations

### For Solo Development
1. Start experiments from `planning-baseline`
2. Use descriptive branch names for different approaches
3. Document learnings in each branch's README
4. Merge successful patterns back to `main`

### For Team Development
1. Assign different approaches to different developers
2. Regular sync meetings to compare progress
3. Shared documentation of lessons learned
4. Collaborative decision on best approach to continue

### For Long-term Maintenance
1. Keep `planning-baseline` as historical reference
2. Tag major milestones in development branches
3. Archive completed experiments with detailed notes
4. Update branching strategy based on learnings

This strategy ensures the valuable planning work is preserved while enabling creative exploration of different development methodologies.
