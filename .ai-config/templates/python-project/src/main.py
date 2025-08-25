"""
FastAPI application entry point for PROJECT_NAME_PLACEHOLDER.

This module provides the main FastAPI application with health checks,
basic routing, and error handling.
"""

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Dict, Any
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Initialize FastAPI app
app = FastAPI(
    title="PROJECT_NAME_PLACEHOLDER",
    description="A containerized Python application",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc"
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure appropriately for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Pydantic models
class HealthResponse(BaseModel):
    status: str
    version: str

class MessageRequest(BaseModel):
    message: str

class MessageResponse(BaseModel):
    echo: str
    length: int

@app.get("/", response_model=Dict[str, str])
async def root():
    """Root endpoint returning basic application info."""
    return {
        "message": "PROJECT_NAME_PLACEHOLDER API",
        "status": "running",
        "docs": "/docs"
    }

@app.get("/health", response_model=HealthResponse)
async def health_check():
    """Health check endpoint for container orchestration."""
    return HealthResponse(
        status="healthy",
        version="1.0.0"
    )

@app.post("/echo", response_model=MessageResponse)
async def echo_message(request: MessageRequest):
    """Echo endpoint for testing API functionality."""
    logger.info(f"Received message: {request.message}")
    
    if not request.message.strip():
        raise HTTPException(status_code=400, detail="Message cannot be empty")
    
    return MessageResponse(
        echo=request.message,
        length=len(request.message)
    )

@app.get("/metrics")
async def metrics():
    """Basic metrics endpoint."""
    return {
        "requests_total": 0,  # Implement proper metrics collection
        "uptime_seconds": 0,
        "memory_usage_mb": 0
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
