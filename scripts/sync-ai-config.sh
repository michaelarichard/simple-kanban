#!/bin/bash
"""
AI Config Sync Script
Synchronizes .ai-config between project-local and global levels.
"""

set -euo pipefail

# Configuration
GLOBAL_AI_CONFIG="/home/windsurf/Projects/.ai-config"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT_AI_CONFIG="${PROJECT_ROOT}/.ai-config"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

show_usage() {
    cat << EOF
AI Config Sync Script

Usage: $0 <command>

Commands:
  pull      Copy global .ai-config to project (overwrites project config)
  push      Copy project .ai-config to global (overwrites global config)
  diff      Show differences between global and project configs
  status    Show sync status and last modified times
  backup    Create backup of current project config
  restore   Restore project config from backup

Examples:
  $0 pull     # Get latest global standards
  $0 push     # Share project customizations globally
  $0 diff     # Review differences before sync
  $0 backup   # Backup before making changes

EOF
}

check_prerequisites() {
    if [[ ! -d "$GLOBAL_AI_CONFIG" ]]; then
        log_error "Global .ai-config not found at $GLOBAL_AI_CONFIG"
        exit 1
    fi
}

sync_pull() {
    log_info "Pulling global .ai-config to project..."
    
    # Backup current project config if it exists
    if [[ -d "$PROJECT_AI_CONFIG" ]]; then
        backup_project_config
    fi
    
    # Copy global config to project
    cp -r "$GLOBAL_AI_CONFIG" "$PROJECT_ROOT/"
    
    log_success "Pulled global .ai-config to project"
    log_info "Project now has latest global standards and workflows"
}

sync_push() {
    log_info "Pushing project .ai-config to global..."
    
    if [[ ! -d "$PROJECT_AI_CONFIG" ]]; then
        log_error "Project .ai-config not found at $PROJECT_AI_CONFIG"
        exit 1
    fi
    
    # Backup global config
    backup_global_config
    
    # Copy project config to global
    cp -r "$PROJECT_AI_CONFIG" "$(dirname "$GLOBAL_AI_CONFIG")/"
    
    log_success "Pushed project .ai-config to global"
    log_warning "All projects will now use these updated standards"
}

show_diff() {
    log_info "Comparing global and project .ai-config..."
    
    if [[ ! -d "$PROJECT_AI_CONFIG" ]]; then
        log_warning "Project .ai-config not found - would be created on pull"
        return
    fi
    
    # Use diff to compare directories
    if diff -r "$GLOBAL_AI_CONFIG" "$PROJECT_AI_CONFIG" > /dev/null 2>&1; then
        log_success "Configurations are identical"
    else
        log_info "Differences found:"
        diff -r "$GLOBAL_AI_CONFIG" "$PROJECT_AI_CONFIG" || true
    fi
}

show_status() {
    log_info "AI Config Sync Status"
    echo
    
    # Global config info
    if [[ -d "$GLOBAL_AI_CONFIG" ]]; then
        global_modified=$(stat -c %Y "$GLOBAL_AI_CONFIG" 2>/dev/null || echo "0")
        global_date=$(date -d "@$global_modified" "+%Y-%m-%d %H:%M:%S" 2>/dev/null || echo "Unknown")
        echo "📁 Global config: $GLOBAL_AI_CONFIG"
        echo "   Last modified: $global_date"
    else
        echo "📁 Global config: Not found"
    fi
    
    echo
    
    # Project config info
    if [[ -d "$PROJECT_AI_CONFIG" ]]; then
        project_modified=$(stat -c %Y "$PROJECT_AI_CONFIG" 2>/dev/null || echo "0")
        project_date=$(date -d "@$project_modified" "+%Y-%m-%d %H:%M:%S" 2>/dev/null || echo "Unknown")
        echo "📁 Project config: $PROJECT_AI_CONFIG"
        echo "   Last modified: $project_date"
        
        # Compare modification times
        if [[ $global_modified -gt $project_modified ]]; then
            log_warning "Global config is newer - consider running 'pull'"
        elif [[ $project_modified -gt $global_modified ]]; then
            log_warning "Project config is newer - consider running 'push'"
        else
            log_success "Configurations have same modification time"
        fi
    else
        echo "📁 Project config: Not found"
        log_info "Run 'pull' to initialize project config"
    fi
}

backup_project_config() {
    local backup_dir="${PROJECT_ROOT}/.ai-config-backups"
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local backup_path="${backup_dir}/ai-config_${timestamp}"
    
    mkdir -p "$backup_dir"
    cp -r "$PROJECT_AI_CONFIG" "$backup_path"
    
    log_success "Backed up project config to $backup_path"
}

backup_global_config() {
    local backup_dir="/home/windsurf/Projects/.ai-config-backups"
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local backup_path="${backup_dir}/ai-config_global_${timestamp}"
    
    mkdir -p "$backup_dir"
    cp -r "$GLOBAL_AI_CONFIG" "$backup_path"
    
    log_success "Backed up global config to $backup_path"
}

create_backup() {
    if [[ ! -d "$PROJECT_AI_CONFIG" ]]; then
        log_error "No project .ai-config to backup"
        exit 1
    fi
    
    backup_project_config
}

restore_backup() {
    local backup_dir="${PROJECT_ROOT}/.ai-config-backups"
    
    if [[ ! -d "$backup_dir" ]]; then
        log_error "No backups found at $backup_dir"
        exit 1
    fi
    
    log_info "Available backups:"
    ls -la "$backup_dir" | grep "ai-config_" || {
        log_error "No .ai-config backups found"
        exit 1
    }
    
    echo
    read -p "Enter backup directory name to restore: " backup_name
    
    local backup_path="${backup_dir}/${backup_name}"
    if [[ ! -d "$backup_path" ]]; then
        log_error "Backup not found: $backup_path"
        exit 1
    fi
    
    # Backup current config before restore
    if [[ -d "$PROJECT_AI_CONFIG" ]]; then
        backup_project_config
    fi
    
    # Restore from backup
    rm -rf "$PROJECT_AI_CONFIG"
    cp -r "$backup_path" "$PROJECT_AI_CONFIG"
    
    log_success "Restored project config from $backup_name"
}

# Main script logic
main() {
    case "${1:-}" in
        pull)
            check_prerequisites
            sync_pull
            ;;
        push)
            check_prerequisites
            sync_push
            ;;
        diff)
            check_prerequisites
            show_diff
            ;;
        status)
            show_status
            ;;
        backup)
            create_backup
            ;;
        restore)
            restore_backup
            ;;
        -h|--help|help)
            show_usage
            ;;
        "")
            log_error "No command specified"
            show_usage
            exit 1
            ;;
        *)
            log_error "Unknown command: $1"
            show_usage
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"
