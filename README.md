# Luke's Flask app
This is a basic Flask web application that can be used to practice the instrumentation of observability solutions. The app currently only works in minikube, however kustomization templates have been added for future EKS/AKS support.

**As of 2025, Docker Desktop and Minikube must be installed to proceed with this exercise!**

If you are reading this on GitHub, you'll need to clone the repository with "git clone https://github.com/squiggleyy/flask-observability-exercise". Once the repo is available on your local machine, complete the following steps:

# Start the app
1. Navigate to the "~/flask-observability-exercise" directory and run the "deploy-app.sh" script via "sh deploy-app.sh".
2. You should be prompted for your DockerHub username. Type your username and click enter.
3. After the script completes, run "kubectl get pods" to confirm that there is a flask-app pod running in the default namespace.
4. Open the application by visiting "http://localhost:5000" in a browser. If it doesn't load, try incognito mode.
5. Interact with the web application to see what it does!

*Now, let's get ready to collect telemetry...*

# Update Observe Helm chart to point to your Observe trial
6. Create a free trial in Observe if you haven't already done so. Log into Observe in the browser.
7. Go to "Add Data" in the left toolbar. Click "Kubernetes" under the section "Observe Agent."
8. Click "Install" and copy the ingest token. Navigate to "deploy-observe.sh" in your terminal or IDE and substitute the existing "observe-token.value" token with your new Kubernetes Exlorer ingest token.
9. Update the Observe tenant endpoint to reflect your own Observe instance, as shown in your URL bar.
10. Save your changes to the file.

# Update Helm values file to point to your Observe trial
11. Go to "Applications" in the left toolbar of the Observe platform. Click on the OpenTelemetry data app tile and install it.
12. Generate your own OpenTelemetry ingest token and copy it. Navigate to "observe-values.yaml" in your terminal or IDE and update the existing Bearer token with your new OpenTelemetry ingest token.
13. Update the traces exporter endpoint to reflect your own Observe instance, as shown in your URL bar.
14. Save your changes to the file.

# Instrument the app with the Observe Agent
15. Navigate to the "~/observe-deployment" folder and run the "deploy-observe.sh" script via "sh deploy-observe.sh".
16. Run "kubectl get pods -n observe" to confirm that 4 pods are running in the observe namespace. It may take a few minutes for them to start running.
17. Run "kubectl get services -n observe" to confirm that 4 services are running in the observe namespace.
18. Go back to the application and click around. This will generate load on the application and will generate corresponding spans that can be sent to Observe.

*If the application doesn't connect, you may have interrupted the port-forwarding. To resume port forwarding, run "kubectl port-forward service/flask-app 5000:5000" in your terminal.*

# View your k8 metrics in Observe!
19. Click "Kubernetes" on the left toolbar of the Observe platform.
20. Notice that you are now observing 1 cluster. Click "Namespaces" to view the different namespaces present in your cluster.
21. Click on the "default" namespace. Notice the flask-app pod that you saw earlier in the terminal. Here you can view the pod's CPU and Memory usage.
22. Click on the flask-app pod. There should be only 1 container in this pod. Here you can view the individual container's CPU and Memory usage.
23. Take a look at the pods in the "observe" namespace as well. These are the Observe Agent pods that you saw earlier in the terminal.

# View your k8 logs in Observe!
24. Click "Logs" and select the "Kubernetes Logs" dataset. Filter to "container = flask-app".
25. Notice that container logs are emitted every time you click around!
26. You can also view these logs directly in the Kubernetes Explorer when looking at a container, pod, node, or namespace.

# View your application traces in Observe!
27. Click "Traces" and take a look at your "service entry point" spans. In the "Operation" column, you'll see the http GET requests from clicking the buttons or refreshing the page.
28. Pick an entry point span and click "View trace." In this case, it is normal to see only 1 span for the trace. Read through the "Fields & attributes" tab.
29. Click the "Logs" tab. Select "Kubernetes Logs" and view those logs for the cluster, pod, and namespace right below the distributed trace! This demonstrates automatic correlation of infrastructure, logs, and traces via resource attributes.