oc create configmap quarkus-podname --from-file=./application.properties
oc set volume deployment/quarkus-podname --add -t configmap --configmap-name=quarkus-podname -m /deployments/config