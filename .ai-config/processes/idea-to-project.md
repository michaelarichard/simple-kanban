---
description: Standard process from simple idea to fully planned project
---

# Idea to Project Workflow

This workflow transforms a simple idea into a fully planned, executable project using our established processes.

## Phase 1: Define & Research (Discovery)

1. **Define Product** (`/project-01-define-product`)
   - Articulate the core problem and solution
   - Identify target users and use cases
   - Define success metrics and constraints
   - Set initial scope boundaries

2. **Product Research** (`/project-02-product-research`)
   - Analyze existing solutions and competitors
   - Identify market opportunities and gaps
   - Research technical approaches and frameworks
   - Validate assumptions and requirements

## Phase 2: Plan & Design (Architecture)

3. **Create User Stories** (`/project-03-create-user-stories`)
   - Transform requirements into actionable user stories
   - Prioritize features by user value
   - Define acceptance criteria
   - Estimate complexity and effort

4. **Design Architecture** (`/project-04-design-architecture`)
   - Design system architecture and components
   - Define data models and API contracts
   - Select technology stack and frameworks
   - Plan deployment and infrastructure

5. **Review Requirements** (`/project-05-review`)
   - Review all requirements for gaps or conflicts
   - Validate technical feasibility
   - Assess resource requirements
   - Finalize project scope

## Phase 3: Initialize & Execute (Implementation)

6. **Generate Project Rules** (`/project-06-generate-rules`)
   - Create project-specific development guidelines
   - Define coding standards and conventions
   - Set up quality gates and processes
   - Establish testing and deployment procedures

7. **Project Initialization** (`/new-project`)
   - Generate containerized project structure
   - Set up development environment
   - Initialize git repository and CI/CD
   - Create initial documentation

8. **Plan Features** (`/project-08-plan-features`)
   - Break down user stories into development tasks
   - Create sprint/milestone planning
   - Define feature development order
   - Set up project tracking and metrics

9. **Develop Features** (`/project-09-develop-feature`)
   - Implement features following TDD approach
   - Maintain code quality standards
   - Conduct code reviews (`/code-review`)
   - Stage and deploy changes (`/stage-changes`)

## Quality Gates

Each phase must meet these criteria before proceeding:

### Phase 1 Complete
- [ ] Problem and solution clearly defined
- [ ] Target users identified and validated
- [ ] Market research completed
- [ ] Technical feasibility confirmed

### Phase 2 Complete
- [ ] User stories prioritized and estimated
- [ ] System architecture designed
- [ ] Technology stack selected
- [ ] Deployment strategy defined

### Phase 3 Ready
- [ ] Development environment set up
- [ ] Project structure initialized
- [ ] Team aligned on standards and processes
- [ ] First milestone planned and ready

## Workflow Execution

Use this sequence for any new project:
```
Idea → /project-01-define-product → /project-02-product-research → 
/project-03-create-user-stories → /project-04-design-architecture → 
/project-05-review → /project-06-generate-rules → /new-project → 
/project-08-plan-features → /project-09-develop-feature
```
