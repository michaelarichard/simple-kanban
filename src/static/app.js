/**
 * Simple Kanban Board - Frontend Application
 * Handles board management, task operations, and drag-and-drop functionality
 */

class KanbanApp {
    constructor() {
        console.log('KanbanApp constructor called');
        this.currentBoard = null;
        this.boards = [];
        this.columns = [];
        this.tasks = [];
        this.draggedTask = null;
        
        console.log('Calling init()...');
        this.init();
    }

    async init() {
        console.log('init() called');
        this.bindEvents();
        console.log('Events bound, loading boards...');
        await this.loadBoards();
        console.log('Boards loaded, hiding loading...');
        this.hideLoading();
        console.log('init() complete');
    }

    bindEvents() {
        // Board management
        document.getElementById('new-board-btn').addEventListener('click', () => this.showBoardModal());
        document.getElementById('create-first-board').addEventListener('click', () => this.showBoardModal());
        document.getElementById('board-select').addEventListener('change', (e) => this.selectBoard(e.target.value));
        document.getElementById('edit-board-btn').addEventListener('click', () => this.editCurrentBoard());

        // Board modal
        document.getElementById('board-modal-close').addEventListener('click', () => this.hideBoardModal());
        document.getElementById('board-cancel').addEventListener('click', () => this.hideBoardModal());
        document.getElementById('board-form').addEventListener('submit', (e) => this.handleBoardSubmit(e));

        // Task modal
        document.getElementById('task-modal-close').addEventListener('click', () => this.hideTaskModal());
        document.getElementById('task-cancel').addEventListener('click', () => this.hideTaskModal());
        document.getElementById('task-form').addEventListener('submit', (e) => this.handleTaskSubmit(e));

        // Notification
        document.getElementById('notification-close').addEventListener('click', () => this.hideNotification());

        // Close modals on backdrop click
        document.getElementById('board-modal').addEventListener('click', (e) => {
            if (e.target.id === 'board-modal') this.hideBoardModal();
        });
        document.getElementById('task-modal').addEventListener('click', (e) => {
            if (e.target.id === 'task-modal') this.hideTaskModal();
        });
    }

    // API Methods
    async apiCall(endpoint, options = {}) {
        try {
            console.log('Making API call to:', `/api${endpoint}`, options);
            const response = await fetch(`/api${endpoint}`, {
                headers: {
                    'Content-Type': 'application/json',
                    ...options.headers
                },
                ...options
            });

            console.log('API Response status:', response.status, response.statusText);

            if (!response.ok) {
                let errorMessage = `HTTP ${response.status}`;
                try {
                    const errorData = await response.json();
                    errorMessage = errorData.detail || errorMessage;
                    console.error('API Error details:', errorData);
                } catch (parseError) {
                    console.error('Failed to parse error response:', parseError);
                    const errorText = await response.text();
                    console.error('Error response text:', errorText);
                }
                throw new Error(errorMessage);
            }

            const data = await response.json();
            console.log('API Response data:', data);
            return data;
        } catch (error) {
            console.error('API Error:', error);
            this.showNotification(error.message || 'Unknown API error', 'error');
            throw error;
        }
    }

    // Board Management
    async loadBoards() {
        try {
            console.log('Loading boards...');
            this.boards = await this.apiCall('/boards/');
            console.log('Boards loaded:', this.boards);
            this.updateBoardSelector();
            
            if (this.boards.length === 0) {
                console.log('No boards found, showing empty state');
                this.showEmptyState();
            } else {
                // Try to restore previously selected board from localStorage
                const savedBoardId = localStorage.getItem('selectedBoardId');
                console.log('Saved board ID from localStorage:', savedBoardId);
                let boardToSelect = null;
                
                if (savedBoardId) {
                    // Check if saved board still exists
                    boardToSelect = this.boards.find(board => board.id == savedBoardId);
                    console.log('Found saved board:', boardToSelect);
                }
                
                // Fall back to first board if saved board not found
                if (!boardToSelect) {
                    boardToSelect = this.boards[0];
                    console.log('Using first board:', boardToSelect);
                }
                
                // Always select the determined board (either saved or first)
                console.log('Selecting board:', boardToSelect.id);
                await this.selectBoard(boardToSelect.id);
            }
        } catch (error) {
            console.error('Error loading boards:', error);
            this.showEmptyState();
        }
    }

    updateBoardSelector() {
        const select = document.getElementById('board-select');
        select.innerHTML = '<option value="">Select a board...</option>';
        
        this.boards.forEach(board => {
            const option = document.createElement('option');
            option.value = board.id;
            option.textContent = board.name;
            select.appendChild(option);
        });
    }

    async selectBoard(boardId) {
        if (!boardId) return;
        
        try {
            this.showLoading();
            this.currentBoard = await this.apiCall(`/boards/${boardId}`);
            document.getElementById('board-select').value = boardId;
            
            // Save selected board to localStorage
            localStorage.setItem('selectedBoardId', boardId);
            
            await this.loadBoardData();
            this.renderBoard();
            this.hideLoading();
        } catch (error) {
            console.error('Failed to load board:', error);
            this.hideLoading();
        }
    }

    async loadBoardData() {
        if (!this.currentBoard) return;

        try {
            // Load columns with tasks
            this.columns = await this.apiCall(`/columns/board/${this.currentBoard.id}`);
            
            // Extract tasks from columns
            this.tasks = [];
            for (const column of this.columns) {
                if (column.tasks) {
                    column.tasks.forEach(task => {
                        task.column_id = column.id;
                        this.tasks.push(task);
                    });
                }
            }
            
            this.renderBoard();
        } catch (error) {
            console.error('Failed to load board data:', error);
        }
    }

    renderBoard() {
        console.log('renderBoard() called');
        console.log('Current board:', this.currentBoard);
        console.log('Columns to render:', this.columns);
        
        // Update board header
        document.getElementById('board-title').textContent = this.currentBoard.name;
        document.getElementById('board-description').textContent = this.currentBoard.description || '';

        // Render columns
        const container = document.getElementById('columns-container');
        console.log('Columns container:', container);
        container.innerHTML = '';

        this.columns.forEach(column => {
            console.log('Creating column element for:', column);
            const columnElement = this.createColumnElement(column);
            container.appendChild(columnElement);
        });
        
        console.log('Board rendered, calling showBoard()');
        this.showBoard();
    }

    createColumnElement(column) {
        const columnTasks = this.tasks.filter(task => task.column_id === column.id);
        
        const columnDiv = document.createElement('div');
        columnDiv.className = 'column';
        columnDiv.dataset.columnId = column.id;
        
        columnDiv.innerHTML = `
            <div class="column-header">
                <div class="column-title">
                    ${column.name}
                    <span class="task-count">${columnTasks.length}</span>
                </div>
                <button class="add-task-btn" data-column-id="${column.id}">
                    <i class="fas fa-plus"></i>
                </button>
            </div>
            <div class="tasks-list" data-column-id="${column.id}">
                ${columnTasks.map(task => this.createTaskHTML(task)).join('')}
            </div>
        `;

        // Add event listeners
        columnDiv.querySelector('.add-task-btn').addEventListener('click', () => {
            this.showTaskModal(column.id);
        });

        // Make column droppable
        const tasksList = columnDiv.querySelector('.tasks-list');
        this.makeDroppable(tasksList);

        return columnDiv;
    }

    createTaskHTML(task) {
        const createdDate = task.created_at ? new Date(task.created_at).toLocaleDateString() : 'Recently';
        const daysOpen = this.calculateDaysOpen(task.created_at);
        
        return `
            <div class="task-card" draggable="true" data-task-id="${task.id}">
                <div class="task-title">${this.escapeHtml(task.title)}</div>
                ${task.description ? `<div class="task-description">${this.escapeHtml(task.description)}</div>` : ''}
                <div class="task-meta">
                    <span>Created: ${createdDate}</span>
                    <span class="days-open ${this.getDaysOpenClass(daysOpen)}">${daysOpen}</span>
                    <div class="task-actions">
                        <button class="task-action edit" data-task-id="${task.id}">
                            <i class="fas fa-edit"></i>
                        </button>
                        <button class="task-action delete" data-task-id="${task.id}">
                            <i class="fas fa-trash"></i>
                        </button>
                    </div>
                </div>
            </div>
        `;
    }

    calculateDaysOpen(createdAt) {
        if (!createdAt) return 'New';
        
        const created = new Date(createdAt);
        const now = new Date();
        const diffTime = Math.abs(now - created);
        const diffDays = Math.floor(diffTime / (1000 * 60 * 60 * 24));
        
        if (diffDays === 0) return 'Today';
        if (diffDays === 1) return '1 day';
        return `${diffDays} days`;
    }

    getDaysOpenClass(daysText) {
        if (daysText === 'New' || daysText === 'Today') return 'days-new';
        
        const days = parseInt(daysText);
        if (isNaN(days)) return 'days-new';
        if (days <= 3) return 'days-fresh';
        if (days <= 7) return 'days-aging';
        return 'days-stale';
    }

    // Drag and Drop
    makeDroppable(element) {
        element.addEventListener('dragover', this.handleDragOver.bind(this));
        element.addEventListener('drop', this.handleDrop.bind(this));
        element.addEventListener('dragenter', this.handleDragEnter.bind(this));
        element.addEventListener('dragleave', this.handleDragLeave.bind(this));

        // Add drag listeners to existing tasks
        element.querySelectorAll('.task-card').forEach(taskCard => {
            this.makeDraggable(taskCard);
        });
    }

    makeDraggable(taskCard) {
        taskCard.addEventListener('dragstart', this.handleDragStart.bind(this));
        taskCard.addEventListener('dragend', this.handleDragEnd.bind(this));
        
        // Add task action listeners
        const editBtn = taskCard.querySelector('.task-action.edit');
        const deleteBtn = taskCard.querySelector('.task-action.delete');
        
        if (editBtn) {
            editBtn.addEventListener('click', (e) => {
                e.stopPropagation();
                this.editTask(taskCard.dataset.taskId);
            });
        }
        
        if (deleteBtn) {
            deleteBtn.addEventListener('click', (e) => {
                e.stopPropagation();
                this.deleteTask(taskCard.dataset.taskId);
            });
        }
    }

    handleDragStart(e) {
        this.draggedTask = e.target;
        e.target.classList.add('dragging');
        e.dataTransfer.effectAllowed = 'move';
        e.dataTransfer.setData('text/html', e.target.outerHTML);
    }

    handleDragEnd(e) {
        e.target.classList.remove('dragging');
        this.draggedTask = null;
    }

    handleDragOver(e) {
        e.preventDefault();
        e.dataTransfer.dropEffect = 'move';
    }

    handleDragEnter(e) {
        e.preventDefault();
        if (e.target.classList.contains('tasks-list')) {
            e.target.parentElement.classList.add('drag-over');
        }
    }

    handleDragLeave(e) {
        if (e.target.classList.contains('tasks-list')) {
            e.target.parentElement.classList.remove('drag-over');
        }
    }

    async handleDrop(e) {
        e.preventDefault();
        
        if (!this.draggedTask) return;
        
        const tasksList = e.target.closest('.tasks-list');
        if (!tasksList) return;
        
        const newColumnId = parseInt(tasksList.dataset.columnId);
        const taskId = parseInt(this.draggedTask.dataset.taskId);
        
        // Remove drag-over class
        tasksList.parentElement.classList.remove('drag-over');
        
        try {
            // Calculate new position (add to end of target column)
            const targetColumnTasks = this.tasks.filter(t => t.column_id === newColumnId);
            const newPosition = targetColumnTasks.length;
            
            // Update task column via API using the move endpoint
            await this.apiCall(`/tasks/${taskId}/move`, {
                method: 'POST',
                body: JSON.stringify({
                    column_id: newColumnId,
                    position: newPosition
                })
            });
            
            // Update local data
            const task = this.tasks.find(t => t.id === taskId);
            if (task) {
                task.column_id = newColumnId;
                task.position = newPosition;
            }
            
            // Re-render the board
            this.renderBoard();
            this.showNotification('Task moved successfully!');
            
        } catch (error) {
            console.error('Failed to move task:', error);
            this.showNotification('Failed to move task. Please try again.', 'error');
        }
    }

    // Task Management
    showTaskModal(columnId = null, task = null) {
        const modal = document.getElementById('task-modal');
        const form = document.getElementById('task-form');
        const title = document.getElementById('task-modal-title');
        const submitBtn = document.getElementById('task-submit');
        
        if (task) {
            // Edit mode
            title.textContent = 'Edit Task';
            submitBtn.textContent = 'Update Task';
            document.getElementById('task-title').value = task.title;
            document.getElementById('task-desc').value = task.description || '';
            document.getElementById('task-id').value = task.id;
            document.getElementById('task-column-id').value = task.column_id;
        } else {
            // Create mode
            title.textContent = 'Create New Task';
            submitBtn.textContent = 'Create Task';
            form.reset();
            document.getElementById('task-column-id').value = columnId;
            document.getElementById('task-id').value = '';
        }
        
        modal.classList.add('show');
    }

    hideTaskModal() {
        document.getElementById('task-modal').classList.remove('show');
    }

    async handleTaskSubmit(e) {
        e.preventDefault();
        
        const formData = new FormData(e.target);
        const taskData = {
            title: formData.get('title'),
            description: formData.get('description') || null,
            column_id: parseInt(formData.get('column_id'))
        };
        
        const taskId = formData.get('id');
        
        try {
            if (taskId) {
                // Update existing task
                await this.apiCall(`/tasks/${taskId}`, {
                    method: 'PUT',
                    body: JSON.stringify(taskData)
                });
                this.showNotification('Task updated successfully!');
            } else {
                // Create new task
                const newTask = await this.apiCall('/tasks/', {
                    method: 'POST',
                    body: JSON.stringify(taskData)
                });
                this.tasks.push(newTask);
                this.showNotification('Task created successfully!');
            }
            
            this.hideTaskModal();
            await this.loadBoardData();
            
        } catch (error) {
            console.error('Failed to save task:', error);
        }
    }

    async editTask(taskId) {
        const task = this.tasks.find(t => t.id === parseInt(taskId));
        if (task) {
            this.showTaskModal(null, task);
        }
    }

    async deleteTask(taskId) {
        if (!confirm('Are you sure you want to delete this task?')) return;
        
        try {
            await this.apiCall(`/tasks/${taskId}`, {
                method: 'DELETE'
            });
            
            this.tasks = this.tasks.filter(t => t.id !== parseInt(taskId));
            this.renderBoard();
            this.showNotification('Task deleted successfully!');
            
        } catch (error) {
            console.error('Failed to delete task:', error);
        }
    }

    // Board Modal Management
    showBoardModal(board = null) {
        const modal = document.getElementById('board-modal');
        const form = document.getElementById('board-form');
        const title = document.getElementById('board-modal-title');
        const submitBtn = document.getElementById('board-submit');
        
        if (board) {
            // Edit mode
            title.textContent = 'Edit Board';
            submitBtn.textContent = 'Update Board';
            document.getElementById('board-name').value = board.name;
            document.getElementById('board-desc').value = board.description || '';
            form.dataset.boardId = board.id; // Store board ID for editing
        } else {
            // Create mode
            title.textContent = 'Create New Board';
            submitBtn.textContent = 'Create Board';
            form.reset();
            delete form.dataset.boardId; // Remove board ID for new boards
        }
        
        modal.classList.add('show');
    }

    hideBoardModal() {
        document.getElementById('board-modal').classList.remove('show');
    }

    async handleBoardSubmit(e) {
        e.preventDefault();
        
        const form = e.target;
        const formData = new FormData(form);
        const boardData = {
            name: formData.get('name'),
            description: formData.get('description') || null
        };
        
        const boardId = form.dataset.boardId;
        
        try {
            if (boardId) {
                // Update existing board
                const updatedBoard = await this.apiCall(`/boards/${boardId}`, {
                    method: 'PUT',
                    body: JSON.stringify(boardData)
                });
                
                this.currentBoard = updatedBoard;
                this.hideBoardModal();
                await this.loadBoards();
                this.renderBoard(); // Re-render with updated info
                this.showNotification('Board updated successfully!');
                
            } else {
                // Create new board (default columns are created by the API)
                const newBoard = await this.apiCall('/boards/', {
                    method: 'POST',
                    body: JSON.stringify(boardData)
                });
                
                this.hideBoardModal();
                await this.loadBoards();
                await this.selectBoard(newBoard.id);
                this.showNotification('Board created successfully!');
            }
            
        } catch (error) {
            console.error('Failed to save board:', error);
        }
    }

    async editCurrentBoard() {
        if (this.currentBoard) {
            this.showBoardModal(this.currentBoard);
        }
    }

    // UI State Management
    showLoading() {
        document.getElementById('loading').style.display = 'flex';
        document.getElementById('empty-state').style.display = 'none';
        document.getElementById('kanban-board').style.display = 'none';
    }

    hideLoading() {
        document.getElementById('loading').style.display = 'none';
    }

    showEmptyState() {
        document.getElementById('loading').style.display = 'none';
        document.getElementById('empty-state').style.display = 'flex';
        document.getElementById('kanban-board').style.display = 'none';
    }

    showBoard() {
        console.log('showBoard() called');
        const loading = document.getElementById('loading');
        const emptyState = document.getElementById('empty-state');
        const kanbanBoard = document.getElementById('kanban-board');
        
        console.log('Loading element:', loading);
        console.log('Empty state element:', emptyState);
        console.log('Kanban board element:', kanbanBoard);
        
        loading.style.display = 'none';
        emptyState.style.display = 'none';
        kanbanBoard.style.display = 'block';
        
        console.log('Board visibility updated');
    }

    // Notifications
    showNotification(message, type = 'success') {
        const notification = document.getElementById('notification');
        const messageEl = document.getElementById('notification-message');
        
        messageEl.textContent = message;
        notification.className = `notification ${type}`;
        notification.classList.add('show');
        
        // Auto-hide after 3 seconds
        setTimeout(() => {
            this.hideNotification();
        }, 3000);
    }

    hideNotification() {
        document.getElementById('notification').classList.remove('show');
    }

    // Utility Methods
    escapeHtml(text) {
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }
}

// Initialize the application when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    console.log('DOM loaded, initializing KanbanApp...');
    const app = new KanbanApp();
    console.log('KanbanApp initialized:', app);
});
