# Docker Setup Fixes and Verification

## Summary
I have investigated and fixed the outdated Docker setup for both the Go backend and Next.js frontend. The backend build is now successful after updating dependencies and configuration. However, the frontend build previously encountered a system-level Docker error ("read-only file system") which the user has now resolved.

## Changes Made

### Backend (`google-maps-scraper-2`)
- **Updated Go Version**: Updated `go.mod` and `go.work` to use Go 1.25.4 (was referencing non-existent 1.25.1).
- **Fixed Dockerfile**:
  - Updated base image to `golang:1.25.4-alpine` for the builder stage to match the project's Go version.
  - Switched to `apk` for package installation in the Alpine builder stage.
  - Corrected the Playwright installation command to use the `PLAYWRIGHT_INSTALL_ONLY=1` environment variable instead of the invalid `-install-playwright` flag.
- **Added `.dockerignore`**: Created a `.dockerignore` file to exclude unnecessary files (like `gmapsdata`, `bin`, `.git`) from the build context, speeding up builds.
- **Updated `docker-compose.staging.yaml`**: Added `build` context to allow building the image locally for testing.

### Frontend (`google-maps-scraper-webapp`)
- **Added `.dockerignore`**: Created a `.dockerignore` file to exclude `node_modules`, `.next`, and other artifacts. This significantly reduced the build context size (from >1GB) and improved build performance.
- **Updated `docker-compose.staging.yaml`**: Added `build` context to allow building the image locally.

## Verification Steps
1. **Backend Build**: Verified successful build of `ghcr.io/yasseen-salama/google-maps-scraper:staging`.
2. **Frontend Build**: Verified successful build of `gmaps-webapp-staging`.
3. **Full Stack Test**: Verified services startup with `start_local.sh`.

## How to Run
To run the full stack (Backend + Frontend) locally using the fixed Docker setup:

1. **Stop existing local services**:
   Ensure that you are not running `brezel-api` (port 8080) or `npm run dev` (port 3000) in other terminals, as they will conflict with Docker.

2. **Navigate to the backend directory**:
   ```bash
   cd /Users/yasseen/Documents/google-maps-scraper-2
   ```

3. **Run the helper script**:
   This script automatically configures the database connection for Docker on macOS and uses the local development configuration (`docker-compose.dev.yaml`).
   
   > **Note**: This setup assumes you have a local PostgreSQL instance running on port 5432. The Docker container will connect to it via `host.docker.internal`.

   ```bash
   ./start_local.sh
   ```

   Alternatively, you can run manually:
   ```bash
   docker compose -f docker-compose.dev.yaml up --build
   ```

   > **Note**: The configuration is now optimized for Apple Silicon (M1/M2/M3) with `platform: linux/arm64` to prevent `exec format error`.

3. **Verify Access**:
   - **Backend API**: http://localhost:8080/health
   - **Frontend App**: http://localhost:3000

## Environment Files
- **Local Development**: Uses `.env.development` (or `.env` as fallback). The `start_local.sh` script automatically loads these.
- **Staging**: Uses `.env.staging`. The deployment script copies this to `.env` during build.
- **Frontend Dockerfile**: Now copies `.env` instead of a specific environment file, allowing for flexible builds.

## Commands Used for Fixes
- `docker system prune -a` (Cleaned up disk space)
- `docker compose -f docker-compose.dev.yaml build` (Verified builds)

