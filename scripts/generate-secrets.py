#!/usr/bin/env python3
"""
Generate secure secrets and app IDs for Simple Kanban Board.
Run this script to initialize production-ready secrets with SOPS encryption.
"""
import secrets
import os
import subprocess
import yaml
from pathlib import Path


def generate_jwt_secret() -> str:
    """Generate JWT secret key."""
    return secrets.token_urlsafe(32)


def generate_session_secret() -> str:
    """Generate session secret key."""
    return secrets.token_urlsafe(32)


def generate_app_id() -> str:
    """Generate unique application ID."""
    return f"app_{secrets.token_urlsafe(16)}"


def generate_api_key() -> str:
    """Generate API key for external integrations."""
    return f"sk_{secrets.token_urlsafe(32)}"


def generate_client_secret() -> str:
    """Generate OAuth2 client secret."""
    return secrets.token_urlsafe(32)


def generate_database_password() -> str:
    """Generate secure database password."""
    return secrets.token_urlsafe(24)


def check_sops_setup():
    """Check if SOPS and GPG are properly configured."""
    try:
        # Check if sops is installed
        subprocess.run(["sops", "--version"], capture_output=True, check=True)
    except (subprocess.CalledProcessError, FileNotFoundError):
        print("❌ SOPS not found. Please install SOPS first:")
        print("   brew install sops  # macOS")
        print("   # or download from https://github.com/mozilla/sops/releases")
        return False
    
    try:
        # Check if GPG keys exist
        result = subprocess.run(["gpg", "--list-secret-keys", "--keyid-format", "LONG"], 
                              capture_output=True, text=True, check=True)
        if not result.stdout.strip():
            print("❌ No GPG secret keys found. Generate one first:")
            print('   export KEY_NAME="your-name"')
            print('   export KEY_COMMENT="key for sops"')
            print('   gpg --batch --full-generate-key <<EOF')
            print('   %no-protection')
            print('   Key-Type: 1')
            print('   Key-Length: 4096')
            print('   Subkey-Type: 1')
            print('   Subkey-Length: 4096')
            print('   Expire-Date: 0')
            print('   Name-Comment: ${KEY_COMMENT}')
            print('   Name-Real: ${KEY_NAME}')
            print('   EOF')
            return False
    except (subprocess.CalledProcessError, FileNotFoundError):
        print("❌ GPG not found. Please install GPG first.")
        return False
    
    return True


def get_gpg_fingerprint():
    """Get the first available GPG key fingerprint."""
    try:
        result = subprocess.run(["gpg", "--list-secret-keys", "--keyid-format", "LONG"], 
                              capture_output=True, text=True, check=True)
        lines = result.stdout.split('\n')
        for line in lines:
            if 'sec' in line and '/' in line:
                # Extract fingerprint from line like: sec   rsa4096/1234567890ABCDEF 2023-01-01
                parts = line.split('/')
                if len(parts) > 1:
                    fingerprint = parts[1].split()[0]
                    return fingerprint
    except subprocess.CalledProcessError:
        pass
    return None


def update_sops_config(fingerprint):
    """Update .sops.yaml with the GPG fingerprint."""
    project_root = Path(__file__).parent.parent
    sops_config = project_root / ".sops.yaml"
    
    if not sops_config.exists():
        print("❌ .sops.yaml not found. Please create it first.")
        return False
    
    # Read and update .sops.yaml
    with open(sops_config, 'r') as f:
        content = f.read()
    
    # Replace placeholder comments with actual fingerprint
    content = content.replace(
        "# Add your GPG key fingerprint here\n      # Example: 1234567890ABCDEF1234567890ABCDEF12345678\n      # Run: gpg --list-secret-keys --keyid-format LONG\n      # Then replace this comment with your key fingerprint",
        fingerprint
    )
    content = content.replace(
        "# Same GPG key fingerprint as above",
        fingerprint
    )
    
    with open(sops_config, 'w') as f:
        f.write(content)
    
    print(f"✅ Updated .sops.yaml with GPG key: {fingerprint}")
    return True


def create_encrypted_secrets(secrets_data):
    """Create SOPS-encrypted secrets files."""
    project_root = Path(__file__).parent.parent
    secrets_dir = project_root / "secrets"
    secrets_dir.mkdir(exist_ok=True)
    
    # Create Kubernetes secret YAML
    k8s_secret = {
        "apiVersion": "v1",
        "kind": "Secret",
        "metadata": {
            "name": "simple-kanban-secrets",
            "namespace": "apps"
        },
        "type": "Opaque",
        "data": {
            "jwt-secret-key": secrets_data["JWT_SECRET_KEY"],
            "session-secret-key": secrets_data["SESSION_SECRET_KEY"],
            "postgres-password": secrets_data["POSTGRES_PASSWORD"],
            "oauth2-client-secret": secrets_data["OAUTH2_CLIENT_SECRET"],
            "api-key": secrets_data["API_KEY"]
        }
    }
    
    # Write unencrypted YAML first
    k8s_secrets_file = secrets_dir / "kubernetes-secrets.yaml"
    with open(k8s_secrets_file, 'w') as f:
        yaml.dump(k8s_secret, f, default_flow_style=False)
    
    # Encrypt with SOPS
    try:
        subprocess.run(["sops", "--encrypt", "--in-place", str(k8s_secrets_file)], check=True)
        print(f"✅ Created encrypted Kubernetes secrets: {k8s_secrets_file}")
    except subprocess.CalledProcessError as e:
        print(f"❌ Failed to encrypt {k8s_secrets_file}: {e}")
        return False
    
    # Create .env.sops file
    env_content = f"""# Simple Kanban Board - Encrypted Environment Variables
# Decrypt with: sops -d .env.sops > .env

# Application
APP_NAME=Simple Kanban Board
APP_ID={secrets_data['APP_ID']}
API_KEY={secrets_data['API_KEY']}

# Security
JWT_SECRET_KEY={secrets_data['JWT_SECRET_KEY']}
SESSION_SECRET_KEY={secrets_data['SESSION_SECRET_KEY']}
OAUTH2_CLIENT_SECRET={secrets_data['OAUTH2_CLIENT_SECRET']}

# Database
POSTGRES_PASSWORD={secrets_data['POSTGRES_PASSWORD']}
"""
    
    env_sops_file = project_root / ".env.sops"
    with open(env_sops_file, 'w') as f:
        f.write(env_content)
    
    # Encrypt .env.sops
    try:
        subprocess.run(["sops", "--encrypt", "--in-place", str(env_sops_file)], check=True)
        print(f"✅ Created encrypted environment file: {env_sops_file}")
    except subprocess.CalledProcessError as e:
        print(f"❌ Failed to encrypt {env_sops_file}: {e}")
        return False
    
    return True


def main():
    """Generate all required secrets and create SOPS-encrypted files."""
    print("🔐 Generating secure secrets for Simple Kanban Board with SOPS...")
    
    # Check prerequisites
    if not check_sops_setup():
        return
    
    # Get GPG fingerprint
    fingerprint = get_gpg_fingerprint()
    if not fingerprint:
        print("❌ Could not find GPG key fingerprint.")
        return
    
    # Update SOPS configuration
    if not update_sops_config(fingerprint):
        return
    
    # Generate all secrets
    secrets_data = {
        "JWT_SECRET_KEY": generate_jwt_secret(),
        "SESSION_SECRET_KEY": generate_session_secret(),
        "APP_ID": generate_app_id(),
        "API_KEY": generate_api_key(),
        "OAUTH2_CLIENT_SECRET": generate_client_secret(),
        "POSTGRES_PASSWORD": generate_database_password(),
    }
    
    # Create SOPS-encrypted secrets
    if not create_encrypted_secrets(secrets_data):
        print("❌ Failed to create encrypted secrets.")
        return
    
    # Create development .env file (unencrypted for local development)
    project_root = Path(__file__).parent.parent
    env_example = project_root / ".env.example"
    env_file = project_root / ".env"
    
    if env_file.exists():
        print(f"⚠️  .env file already exists at {env_file}")
        response = input("Do you want to overwrite it? (y/N): ")
        if response.lower() != 'y':
            print("❌ Skipping .env file creation.")
        else:
            # Read template and replace placeholders
            with open(env_example, 'r') as f:
                content = f.read()
            
            # Replace placeholder values
            content = content.replace("your-jwt-secret-key-here", secrets_data["JWT_SECRET_KEY"])
            content = content.replace("your-session-secret-key-here", secrets_data["SESSION_SECRET_KEY"])
            content = content.replace("your-oauth2-client-secret", secrets_data["OAUTH2_CLIENT_SECRET"])
            content = content.replace("kanban", "kanban")  # Keep default username
            content = content.replace("POSTGRES_PASSWORD=kanban", f"POSTGRES_PASSWORD={secrets_data['POSTGRES_PASSWORD']}")
            
            # Write .env file
            with open(env_file, 'w') as f:
                f.write(content)
            
            print(f"✅ Created .env file at {env_file}")
    else:
        # Read template and replace placeholders
        with open(env_example, 'r') as f:
            content = f.read()
        
        # Replace placeholder values
        content = content.replace("your-jwt-secret-key-here", secrets_data["JWT_SECRET_KEY"])
        content = content.replace("your-session-secret-key-here", secrets_data["SESSION_SECRET_KEY"])
        content = content.replace("your-oauth2-client-secret", secrets_data["OAUTH2_CLIENT_SECRET"])
        content = content.replace("kanban", "kanban")  # Keep default username
        content = content.replace("POSTGRES_PASSWORD=kanban", f"POSTGRES_PASSWORD={secrets_data['POSTGRES_PASSWORD']}")
        
        # Write .env file
        with open(env_file, 'w') as f:
            f.write(content)
        
        print(f"✅ Created .env file at {env_file}")
    print("\n🔑 Generated secrets:")
    print(f"   App ID: {secrets_data['APP_ID']}")
    print(f"   API Key: {secrets_data['API_KEY'][:20]}...")
    print(f"   JWT Secret: {secrets_data['JWT_SECRET_KEY'][:20]}...")
    print(f"   Session Secret: {secrets_data['SESSION_SECRET_KEY'][:20]}...")
    print(f"   OAuth2 Secret: {secrets_data['OAUTH2_CLIENT_SECRET'][:20]}...")
    print(f"   DB Password: {secrets_data['POSTGRES_PASSWORD'][:20]}...")
    
    print("\n📝 Next steps:")
    print("   1. Review the .env file for local development")
    print("   2. Use encrypted files for production deployment:")
    print("      - secrets/kubernetes-secrets.yaml (for K8s)")
    print("      - .env.sops (for environment variables)")
    print("   3. Decrypt when needed: sops -d .env.sops > .env")
    print("   4. Never commit .env to version control (encrypted files are safe)")
    print("   5. Share GPG public key with team members for collaboration")
    
    # Create secrets documentation
    secrets_doc = project_root / "docs" / "secrets-management.md"
    with open(secrets_doc, 'w') as f:
        f.write(f"""# Secrets Management

## Generated Application Credentials

**Application ID**: `{secrets_data['APP_ID']}`
**API Key**: `{secrets_data['API_KEY']}`

## Security Notes

1. **JWT Secret**: Used for signing access tokens
2. **Session Secret**: Used for session cookie encryption
3. **OAuth2 Client Secret**: For external OAuth2 integrations
4. **Database Password**: PostgreSQL user password

## Production Deployment

For production environments:

1. Use Kubernetes secrets or cloud provider secret management
2. Rotate secrets regularly (every 90 days recommended)
3. Use different secrets for each environment (dev/staging/prod)
4. Monitor for secret exposure in logs or error messages

## Environment Variables

```bash
# Required for production
export JWT_SECRET_KEY="{secrets_data['JWT_SECRET_KEY']}"
export SESSION_SECRET_KEY="{secrets_data['SESSION_SECRET_KEY']}"
export POSTGRES_PASSWORD="{secrets_data['POSTGRES_PASSWORD']}"
```

## Kubernetes Secrets

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: simple-kanban-secrets
type: Opaque
data:
  jwt-secret-key: <base64-encoded-value>
  session-secret-key: <base64-encoded-value>
  postgres-password: <base64-encoded-value>
```
""")
    
    print(f"📚 Created secrets documentation at {secrets_doc}")


if __name__ == "__main__":
    main()
