#!/bin/bash

# Check if Docker username is provided, prompt the user if not set
if [[ -z "$DOCKER_USERNAME" ]]; then
  read -p "Enter your Docker Hub username: " DOCKER_USERNAME
  if [[ -z "$DOCKER_USERNAME" ]]; then
    echo "Error: Docker Hub username is required!"
    exit 1
  fi
fi

# Set variables
APP_NAME="flask-app"
NAMESPACE="default"
DOCKER_IMAGE="$DOCKER_USERNAME/$APP_NAME:latest"
CLUSTER_TYPE=${1:-"minikube"}  # Default to minikube
OVERLAY_DIR="./overlays/$CLUSTER_TYPE"

# Check Minikube
function check_minikube() {
  if [[ "$CLUSTER_TYPE" == "minikube" ]]; then
    echo "Checking Minikube status..."
    if ! minikube status >/dev/null 2>&1; then
      echo "Minikube is not running. Attempting to start Minikube..."
      minikube start
      if [ $? -ne 0 ]; then
        echo "Failed to start Minikube. Please check Minikube logs with 'minikube logs'."
        exit 1
      fi
    else
      echo "Minikube is already running."
    fi
  fi
}

# Check Docker daemon
function check_docker() {
  echo "Checking Docker daemon..."
  if ! docker info >/dev/null 2>&1; then
    echo "Docker daemon is not running. Please start Docker and try again."
    exit 1
  fi
}

# Cleanup previous deployment
function cleanup_deployment() {
  echo "Checking for existing deployment and services..."
  kubectl delete deployment $APP_NAME service $APP_NAME --ignore-not-found
}

# Build and push Docker image
function deploy_application() {
  echo "Building Docker image..."
  docker build -t $DOCKER_IMAGE ./base

  echo "Pushing Docker image..."
  if [[ "$CLUSTER_TYPE" == "minikube" ]]; then
    echo "Loading image into Minikube..."
    minikube image load $DOCKER_IMAGE
  else
    docker push $DOCKER_IMAGE
  fi

  echo "Updating Kustomize with the correct image..."
  sed -i '' "s|DOCKER_IMAGE|$DOCKER_IMAGE|g" $OVERLAY_DIR/kustomization.yaml

  echo "Deploying $CLUSTER_TYPE overlay with Kustomize via directory $OVERLAY_DIR ..."
  kubectl apply -k $OVERLAY_DIR
}

# Start port forwarding
function start_port_forwarding() {
  if [[ "$CLUSTER_TYPE" == "minikube" ]]; then
    echo "Starting port forwarding for Minikube..."
    kubectl port-forward service/$APP_NAME 5000:5000 > /dev/null 2>&1 &
    PORT_FORWARD_PID=$!
    echo "Port forwarding started. App is available at http://127.0.0.1:5000"
  fi
}

# Open the browser
function open_browser() {
  if [[ "$CLUSTER_TYPE" == "minikube" ]]; then
    echo "Opening browser to http://127.0.0.1:5000"
    open http://127.0.0.1:5000 || xdg-open http://127.0.0.1:5000 || echo "Please open http://127.0.0.1:5000 manually."
  else
    echo "For non-Minikube clusters, access the app via the external IP or LoadBalancer."
  fi
}

# Main execution
check_docker
check_minikube
cleanup_deployment
deploy_application
start_port_forwarding
open_browser

echo "Deployment complete!"