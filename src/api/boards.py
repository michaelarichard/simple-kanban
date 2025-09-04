"""
Board management API routes.

Provides CRUD operations for kanban boards.
"""
from typing import List, Optional
from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from pydantic import BaseModel

from ..database import get_db
from ..models import Board, Column

router = APIRouter(prefix="/boards", tags=["boards"])


# Pydantic schemas
class BoardCreate(BaseModel):
    name: str
    description: Optional[str] = None


class BoardUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None


class BoardResponse(BaseModel):
    id: int
    name: str
    description: Optional[str]
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


class BoardWithColumnsResponse(BoardResponse):
    columns: List[dict] = []


@router.post("/", response_model=BoardResponse, status_code=status.HTTP_201_CREATED)
async def create_board(board: BoardCreate, db: Session = Depends(get_db)):
    """Create a new kanban board with default columns."""
    # Create the board
    db_board = Board(name=board.name, description=board.description)
    db.add(db_board)
    db.flush()  # Get the board ID
    
    # Create default columns
    default_columns = [
        {"name": "To Do", "position": 0},
        {"name": "In Progress", "position": 1},
        {"name": "Done", "position": 2}
    ]
    
    for col_data in default_columns:
        db_column = Column(
            name=col_data["name"],
            position=col_data["position"],
            board_id=db_board.id
        )
        db.add(db_column)
    
    db.commit()
    db.refresh(db_board)
    return db_board


@router.get("/", response_model=List[BoardResponse])
async def list_boards(db: Session = Depends(get_db)):
    """List all kanban boards."""
    boards = db.query(Board).all()
    return boards


@router.get("/{board_id}", response_model=BoardWithColumnsResponse)
async def get_board(board_id: int, db: Session = Depends(get_db)):
    """Get a specific board with its columns and tasks."""
    board = db.query(Board).filter(Board.id == board_id).first()
    if not board:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Board not found"
        )
    
    # Convert to dict and add columns
    board_dict = {
        "id": board.id,
        "name": board.name,
        "description": board.description,
        "created_at": board.created_at,
        "updated_at": board.updated_at,
        "columns": [
            {
                "id": col.id,
                "name": col.name,
                "position": col.position,
                "tasks": [
                    {
                        "id": task.id,
                        "title": task.title,
                        "description": task.description,
                        "position": task.position
                    }
                    for task in col.tasks
                ]
            }
            for col in board.columns
        ]
    }
    
    return board_dict


@router.put("/{board_id}", response_model=BoardResponse)
async def update_board(
    board_id: int, 
    board_update: BoardUpdate, 
    db: Session = Depends(get_db)
):
    """Update a board's name or description."""
    board = db.query(Board).filter(Board.id == board_id).first()
    if not board:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Board not found"
        )
    
    if board_update.name is not None:
        board.name = board_update.name
    if board_update.description is not None:
        board.description = board_update.description
    
    db.commit()
    db.refresh(board)
    return board


@router.get("/{board_id}/columns")
async def get_board_columns(board_id: int, db: Session = Depends(get_db)):
    """Get all columns for a specific board."""
    board = db.query(Board).filter(Board.id == board_id).first()
    if not board:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Board not found"
        )
    
    columns = db.query(Column).filter(Column.board_id == board_id).order_by(Column.position).all()
    return [
        {
            "id": col.id,
            "name": col.name,
            "position": col.position,
            "board_id": col.board_id
        }
        for col in columns
    ]


@router.delete("/{board_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_board(board_id: int, db: Session = Depends(get_db)):
    """Delete a board and all its columns and tasks."""
    board = db.query(Board).filter(Board.id == board_id).first()
    if not board:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Board not found"
        )
    
    db.delete(board)
    db.commit()
