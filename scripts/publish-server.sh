#!/bin/bash

# Truco Server Docker Publishing Script
# Usage: ./scripts/publish-server.sh <version> [docker-username]
#
# Example: ./scripts/publish-server.sh 1.0.0 tobaginfernandes

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

if [ -z "$1" ]; then
    echo -e "${RED}Error: Version number required${NC}"
    echo "Usage: $0 <version> [docker-username]"
    echo "Example: $0 1.0.0 tobaginfernandes"
    exit 1
fi

VERSION=$1
DOCKER_USERNAME=${2:-tobaginfernandes}
IMAGE_NAME="truco-server"
FULL_IMAGE_NAME="${DOCKER_USERNAME}/${IMAGE_NAME}"

if ! [[ $VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo -e "${RED}Error: Invalid version format${NC}"
    echo "Version must be in format: major.minor.patch (e.g., 1.0.0)"
    exit 1
fi

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Truco Server Docker Publisher${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${GREEN}Version:${NC} ${VERSION}"
echo -e "${GREEN}Docker Hub Username:${NC} ${DOCKER_USERNAME}"
echo -e "${GREEN}Image:${NC} ${FULL_IMAGE_NAME}"
echo ""

if ! command -v docker &> /dev/null; then
    echo -e "${RED}Error: Docker is not installed${NC}"
    exit 1
fi

if ! docker info 2>/dev/null | grep -q "Username"; then
    echo -e "${YELLOW}Warning: Not logged into Docker Hub${NC}"
    echo -e "${YELLOW}Please run: docker login${NC}"
    read -p "Do you want to login now? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker login
    else
        exit 1
    fi
fi

cd "$(dirname "$0")/../server" || exit 1

echo -e "${BLUE}📦 Building Docker image...${NC}"
docker build -t ${IMAGE_NAME} .

echo -e "${GREEN}✅ Build successful${NC}"
echo ""

echo -e "${BLUE}🏷️  Tagging images...${NC}"
docker tag ${IMAGE_NAME} ${FULL_IMAGE_NAME}:${VERSION}
docker tag ${IMAGE_NAME} ${FULL_IMAGE_NAME}:latest

echo -e "${GREEN}✅ Tagged: ${FULL_IMAGE_NAME}:${VERSION}${NC}"
echo -e "${GREEN}✅ Tagged: ${FULL_IMAGE_NAME}:latest${NC}"
echo ""

echo -e "${BLUE}🚀 Pushing to Docker Hub...${NC}"
docker push ${FULL_IMAGE_NAME}:${VERSION}
docker push ${FULL_IMAGE_NAME}:latest

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  ✅ Successfully Published!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "📦 Images published:"
echo -e "   • ${FULL_IMAGE_NAME}:${VERSION}"
echo -e "   • ${FULL_IMAGE_NAME}:latest"
echo ""
echo -e "🐳 Pull command:"
echo -e "   ${BLUE}docker pull ${FULL_IMAGE_NAME}:${VERSION}${NC}"
echo ""
echo -e "🚀 Run command:"
echo -e "   ${BLUE}docker run -d -p 8444:8443 ${FULL_IMAGE_NAME}:${VERSION}${NC}"
echo ""
