"""
Configuration management for Simple Kanban Board application.
"""
import os
import secrets
from typing import List, Optional
from pydantic import BaseSettings, validator


class Settings(BaseSettings):
    """Application settings with environment variable support."""
    
    # Application Configuration
    app_name: str = "Simple Kanban Board"
    app_version: str = "1.0.0"
    environment: str = "development"
    debug: bool = False
    
    # API Configuration
    api_v1_str: str = "/api/v1"
    project_name: str = "Simple Kanban Board"
    project_description: str = "Self-hosted kanban board with story planning"
    
    # Security Configuration
    jwt_secret_key: str = secrets.token_urlsafe(32)
    jwt_access_token_expire_minutes: int = 15
    jwt_refresh_token_expire_days: int = 7
    session_secret_key: str = secrets.token_urlsafe(32)
    session_cookie_secure: bool = False
    session_cookie_httponly: bool = True
    session_cookie_samesite: str = "lax"
    
    # Database Configuration
    database_url: str = "postgresql+asyncpg://kanban:kanban@localhost:5432/simple_kanban"
    postgres_host: str = "localhost"
    postgres_port: int = 5432
    postgres_db: str = "simple_kanban"
    postgres_user: str = "kanban"
    postgres_password: str = "kanban"
    
    # Redis Configuration
    redis_url: str = "redis://localhost:6379/0"
    redis_host: str = "localhost"
    redis_port: int = 6379
    redis_password: Optional[str] = None
    redis_db: int = 0
    
    # CORS Configuration
    backend_cors_origins: List[str] = [
        "http://localhost:3000",
        "http://localhost:8000", 
        "http://localhost:8080"
    ]
    
    @validator("backend_cors_origins", pre=True)
    def assemble_cors_origins(cls, v):
        if isinstance(v, str):
            return [i.strip() for i in v.split(",")]
        elif isinstance(v, list):
            return v
        raise ValueError(v)
    
    # OAuth2 Configuration
    oauth2_client_id: Optional[str] = None
    oauth2_client_secret: Optional[str] = None
    oauth2_redirect_uri: str = "http://localhost:8000/auth/callback"
    
    # Email Configuration
    smtp_host: str = "localhost"
    smtp_port: int = 587
    smtp_user: Optional[str] = None
    smtp_password: Optional[str] = None
    smtp_tls: bool = True
    email_from: str = "noreply@simple-kanban.local"
    
    # File Upload Configuration
    max_upload_size: int = 10485760  # 10MB
    upload_path: str = "/app/uploads"
    
    # Rate Limiting
    rate_limit_per_minute: int = 100
    rate_limit_burst: int = 200
    
    # Logging Configuration
    log_level: str = "INFO"
    log_format: str = "json"
    
    # Monitoring Configuration
    enable_metrics: bool = True
    metrics_port: int = 9090
    
    # Server Configuration
    host: str = "0.0.0.0"
    port: int = 8000
    reload: bool = False
    
    # Testing Configuration
    test_database_url: str = "postgresql+asyncpg://kanban:kanban@localhost:5432/simple_kanban_test"
    
    class Config:
        env_file = ".env"
        case_sensitive = False


# Global settings instance
settings = Settings()


def get_settings() -> Settings:
    """Get application settings."""
    return settings
