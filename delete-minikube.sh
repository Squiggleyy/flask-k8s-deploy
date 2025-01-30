# Stops minikube
echo "Stopping minikube..."
minikube stop

# Deletes minikube
echo "Deleting minikube..."
minikube delete

# Clears minikube directory
echo "Clearing minikube directory..."
rm -rf ~/.minikube

# Confirm that the app is torn down
echo "App has been torn down!"