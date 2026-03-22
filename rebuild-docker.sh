#!/bin/bash

# Rebuild Docker script for Evolution Manager V2
# Usage: ./rebuild-docker.sh [options]
# Options:
#   --no-cache    Build without cache
#   --logs        Follow logs after rebuild
#   --help        Show this help message

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Parse arguments
NO_CACHE=""
FOLLOW_LOGS=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --no-cache)
      NO_CACHE="--no-cache"
      echo -e "${YELLOW}Building without cache...${NC}"
      shift
      ;;
    --logs)
      FOLLOW_LOGS=true
      shift
      ;;
    --help)
      echo "Usage: ./rebuild-docker.sh [options]"
      echo "Options:"
      echo "  --no-cache    Build without cache"
      echo "  --logs        Follow logs after rebuild"
      echo "  --help        Show this help message"
      exit 0
      ;;
    *)
      echo -e "${RED}Unknown option: $1${NC}"
      exit 1
      ;;
  esac
done

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Evolution Manager V2 Docker Rebuild  ${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Stop and remove existing containers
echo -e "${YELLOW}Stopping existing containers...${NC}"
docker-compose down

# Remove old images (optional cleanup)
echo -e "${YELLOW}Cleaning up old images...${NC}"
docker images | grep "evolution-manager-v2" | awk '{print $3}' | xargs -r docker rmi -f 2>/dev/null || true

# Build new image
echo -e "${YELLOW}Building new Docker image...${NC}"
docker-compose build $NO_CACHE

# Start containers
echo -e "${YELLOW}Starting containers...${NC}"
docker-compose up -d

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Rebuild completed successfully!       ${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Show container status
echo -e "${YELLOW}Container status:${NC}"
docker-compose ps

echo ""
echo -e "${GREEN}Evolution Manager V2 is running at: http://localhost:3000${NC}"

# Follow logs if requested
if [ "$FOLLOW_LOGS" = true ]; then
  echo ""
  echo -e "${YELLOW}Following logs (Ctrl+C to exit)...${NC}"
  docker-compose logs -f
fi
