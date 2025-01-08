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
DOCKER_IMAGE="$DOCKER_USERNAME/$APP_NAME" #:latest"
CLUSTER_TYPE=${1:-"minikube"}  # Default to minikube
OVERLAY_DIR="./overlays/$CLUSTER_TYPE"

echo "DOCKER_IMAGE: $DOCKER_IMAGE"

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

  echo "OVERLAY_DIR: $OVERLAY_DIR"
  echo "APP_NAME: $APP_NAME"
  echo "DOCKER_IMAGE: $DOCKER_IMAGE"

  #cd $OVERLAY_DIR
  #$APP_NAME=$DOCKER_IMAGE
  #echo "New APP_NAME: $APP_NAME"
  cd ./base || exit 1
  #kustomize edit set image $APP_NAME=$DOCKER_IMAGE
  #kustomize edit set image $APP_NAME
  echo "Current directory: $(pwd)"
  #sed -i '' "s|PLACEHOLDER_IMAGE|$DOCKER_IMAGE|g" kustomization.yaml
  sed -i '' "s|PLACEHOLDER_IMAGE|$DOCKER_IMAGE|g" kustomization.yaml

  new_name=$(yq '.images[] | select(.name == "flask-app:latest").newName' kustomization.yaml)
  echo "The current image newName is: $new_name"

  #kustomize edit set image squiggleyy/flask-app:latest
  #$APP_NAME=$DOCKER_IMAGE
  #echo "New APP_NAME: $APP_NAME"
  cd - >/dev/null

  #docker login

  echo "Deploying $CLUSTER_TYPE overlay with Kustomize via directory $OVERLAY_DIR ..."
  kubectl apply -k $OVERLAY_DIR
  echo "Deployment complete!"
}

# Start port forwarding
function start_port_forwarding() {
  if [[ "$CLUSTER_TYPE" == "minikube" ]]; then
    echo "Starting port forwarding for Minikube... APP_NAME is $APP_NAME"
    sleep 5 # Wait 5s to give the pod time to start before port forward
    echo "Port forwarding started. App is available at http://127.0.0.1:5000"
    kubectl port-forward service/$APP_NAME 5000:5000 # > /dev/null 2>&1 &
    # PORT_FORWARD_PID=$!
  fi
}

# Open the browser
function open_browser() {
  echo "Please open http://127.0.0.1:5000 manually in an incognito window."
}

# Open the browser
# function open_browser() {
#   if [[ "$CLUSTER_TYPE" == "minikube" ]]; then
#     echo "Opening browser to http://127.0.0.1:5000 in incognito mode"
    
#     # Check if Google Chrome is installed
#     if command -v google-chrome >/dev/null 2>&1; then
#       google-chrome --incognito http://127.0.0.1:5000
#     elif command -v chrome >/dev/null 2>&1; then
#       chrome --incognito http://127.0.0.1:5000
#     elif command -v open >/dev/null 2>&1; then
#       # macOS fallback: Use open command with Chrome in incognito
#       open -a "Google Chrome" --args --incognito http://127.0.0.1:5000
#     else
#       echo "Please open http://127.0.0.1:5000 manually in an incognito window."
#     fi
#   else
#     echo "For non-Minikube clusters, access the app via the external IP or LoadBalancer."
#   fi
# }

# Open the browser
# function open_browser() {
#   if [[ "$CLUSTER_TYPE" == "minikube" ]]; then
#     echo "Opening browser to http://127.0.0.1:5000"
#     open http://127.0.0.1:5000 || xdg-open http://127.0.0.1:5000 || echo "Please open http://127.0.0.1:5000 manually."
#   else
#     echo "For non-Minikube clusters, access the app via the external IP or LoadBalancer."
#   fi
# }

# Main execution
check_docker
check_minikube
cleanup_deployment
deploy_application
open_browser
start_port_forwarding