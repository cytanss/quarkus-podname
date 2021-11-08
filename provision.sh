#!/bin/bash

echo "###############################################################################"
echo "#  MAKE SURE YOU ARE LOGGED IN:                                               #"
echo "#  $ oc login http://api.your.openshift.com                                   #"
echo "###############################################################################"

################################################################################
# Deploy Function                                                              #
################################################################################

LOGGEDIN_USER=$(oc whoami)
DEFAULT_PASSWORD="admin123"

function deploy() {

  #START : Use for scripts testing purposes
  #oc delete project swift-sit cicd-utils
  #oc patch hawtio/fuse-console --type=merge -p '{"metadata": {"finalizers":null}}'
  #sleep 30
  
  read -p "Enter Your OpenShift Wildcard Domain: "  WILDCARD_DOMAIN
  #WILDCARD_DOMAIN="apps.cluster-br5kw.br5kw.example.opentlc.com"

  echo "Wild Card entered: $WILDCARD_DOMAIN"
  #echo "Username entered: $RUSERNAME"
  #echo "Password entered: $RPASSWORD"
  read -p "Press Enter Y to confirm to proceed? " CONFIRMED
  
  if [ -z "$CONFIRMED" ];
  then
    echo "Cancel Provisioning!"
    exit 0
  else
    if  [ $CONFIRMED != "Y" ] && [ $CONFIRMED != "y" ];
    then
        echo "Cancel Provisioning!"
        exit 0
    fi
  fi

  #Setup quarkus-sit
  oc new-project quarkus-sit
  oc apply -f pipeline/configmap/maven-config.yaml
  oc apply -f pipeline/pvc/working-pvc.yaml

  #Setup tasks and pipeline
  read -p "Press Enter Y to confirm to proceed setup tasks and pipeline? " CONFIRMED
  
  if [ -z "$CONFIRMED" ];
  then
    echo "Cancel Provisioning!"
    exit 0
  else
    if  [ $CONFIRMED != "Y" ] && [ $CONFIRMED != "y" ];
    then
        echo "Cancel Provisioning!"
        exit 0
    fi
  fi

  oc apply -f pipeline/tasks/
  oc apply -f pipeline/pipelines/quarkus-podname-cicd.yaml
  

exit 0

  #Setup Gitea & Nexus
  read -p "Press Enter Y to confirm to setup GITEA and NEXUS? " CONFIRMED2
  
  if [ ! -z "$CONFIRMED2" ] && [ $CONFIRMED2 == "Y" ] || [ $CONFIRMED2 == "y" ];
  then
    #echo "Setting up Gitea and Nexus!!"
    oc new-project cicd-utils
    oc new-app -f templates/cicd-utils/gitea-persistent-template.yaml -p HOSTNAME='gitea.'$WILDCARD_DOMAIN -n cicd-utils
    oc new-app -f templates/cicd-utils/nexus3-persistent-template.yaml -n cicd-utils

    sleep 2
    echo_header "Manual login to nexus and update password to "$DEFAULT_PASSWORD
    read -p "Press Enter to continus? " CONFIRMED2

    echo_header "Start configuring NEXUS with red hat maven repo"
    sleep 20
    echo admin:$DEFAULT_PASSWORD
    #setup red hat maven repo into nexus
    curl -u admin:$DEFAULT_PASSWORD -i -X 'POST' \
      'http://nexus3-cicd-utils.'$WILDCARD_DOMAIN'/service/rest/v1/repositories/maven/proxy' \
      -H 'accept: application/json' \
      -H 'Content-Type: application/json' \
      -d @templates/cicd-utils/jboss-early-access-repository.json
    sleep 3
    curl -u admin:$DEFAULT_PASSWORD -i -X 'POST' \
      'http://nexus3-cicd-utils.'$WILDCARD_DOMAIN'/service/rest/v1/repositories/maven/proxy' \
      -H 'accept: application/json' \
      -H 'Content-Type: application/json' \
      -d @templates/cicd-utils/jboss-ga-repository.json
    sleep 3
    curl -u admin:$DEFAULT_PASSWORD -i -X 'PUT' \
      'http://nexus3-cicd-utils.'$WILDCARD_DOMAIN'/service/rest/v1/repositories/maven/group/maven-public' \
      -H 'accept: application/json' \
      -H 'Content-Type: application/json' \
      -d @templates/cicd-utils/update-maven-public.json
    sleep 3

    #upload transformer project jars into nexus
    echo_header "Start configuring NEXUS with uploading transformer project jars"
    curl -u admin:$DEFAULT_PASSWORD -i -X 'POST' \
      'http://nexus3-cicd-utils.'$WILDCARD_DOMAIN'/service/rest/v1/components?repository=maven-releases' \
      -H 'accept: application/json' \
      -H 'Content-Type: multipart/form-data' \
      -F 'maven2.groupId=com.alliance' \
      -F 'maven2.artifactId=pacsToPrinted' \
      -F 'maven2.version=1.0.0' \
      -F 'maven2.asset1=@../transformer-project/Bank_Alliance/build/pacsToPrinted-1.0.0.jar' \
      -F 'maven2.asset1.extension=jar' \
      -F 'maven2.generate-pom=true'
    sleep 3
    curl -u admin:$DEFAULT_PASSWORD -i -X 'POST' \
      'http://nexus3-cicd-utils.'$WILDCARD_DOMAIN'/service/rest/v1/components?repository=maven-releases' \
      -H 'accept: application/json' \
      -H 'Content-Type: multipart/form-data' \
      -F 'maven2.groupId=com.alliance' \
      -F 'maven2.artifactId=pacsToRentas' \
      -F 'maven2.version=1.0.0' \
      -F 'maven2.asset1=@../transformer-project/Bank_Alliance/build/pacsToRentas-1.0.0.jar' \
      -F 'maven2.asset1.extension=jar' \
      -F 'maven2.generate-pom=true'
    sleep 3
    curl -u admin:$DEFAULT_PASSWORD -i -X 'POST' \
      'http://nexus3-cicd-utils.'$WILDCARD_DOMAIN'/service/rest/v1/components?repository=maven-releases' \
      -H 'accept: application/json' \
      -H 'Content-Type: multipart/form-data' \
      -F 'maven2.groupId=com.alliance' \
      -F 'maven2.artifactId=rentasToPacs' \
      -F 'maven2.version=1.0.0' \
      -F 'maven2.asset1=@../transformer-project/Bank_Alliance/build/rentasToPacs-1.0.0.jar' \
      -F 'maven2.asset1.extension=jar' \
      -F 'maven2.generate-pom=true'
    sleep 3    
    curl -u admin:$DEFAULT_PASSWORD -i -X 'POST' \
      'http://nexus3-cicd-utils.'$WILDCARD_DOMAIN'/service/rest/v1/components?repository=maven-releases' \
      -H 'accept: application/json' \
      -H 'Content-Type: multipart/form-data' \
      -F 'maven2.groupId=com.alliance' \
      -F 'maven2.artifactId=rentasToSwift' \
      -F 'maven2.version=1.0.0' \
      -F 'maven2.asset1=@../transformer-project/Bank_Alliance/build/rentasToSwift-1.0.0.jar' \
      -F 'maven2.asset1.extension=jar' \
      -F 'maven2.generate-pom=true'
    sleep 3
    curl -u admin:$DEFAULT_PASSWORD -i -X 'POST' \
      'http://nexus3-cicd-utils.'$WILDCARD_DOMAIN'/service/rest/v1/components?repository=maven-releases' \
      -H 'accept: application/json' \
      -H 'Content-Type: multipart/form-data' \
      -F 'maven2.groupId=com.alliance' \
      -F 'maven2.artifactId=swiftToPrinted' \
      -F 'maven2.version=1.0.0' \
      -F 'maven2.asset1=@../transformer-project/Bank_Alliance/build/swiftToPrinted-1.0.0.jar' \
      -F 'maven2.asset1.extension=jar' \
      -F 'maven2.generate-pom=true'
    sleep 3    
    curl -u admin:$DEFAULT_PASSWORD -i -X 'POST' \
      'http://nexus3-cicd-utils.'$WILDCARD_DOMAIN'/service/rest/v1/components?repository=maven-releases' \
      -H 'accept: application/json' \
      -H 'Content-Type: multipart/form-data' \
      -F 'maven2.groupId=com.alliance' \
      -F 'maven2.artifactId=swiftToRentas' \
      -F 'maven2.version=1.0.0' \
      -F 'maven2.asset1=@../transformer-project/Bank_Alliance/build/swiftToRentas-1.0.0.jar' \
      -F 'maven2.asset1.extension=jar' \
      -F 'maven2.generate-pom=true'
    sleep 3
    curl -u admin:$DEFAULT_PASSWORD -i -X 'POST' \
      'http://nexus3-cicd-utils.'$WILDCARD_DOMAIN'/service/rest/v1/components?repository=maven-releases' \
      -H 'accept: application/json' \
      -H 'Content-Type: multipart/form-data' \
      -F 'maven2.groupId=com.alliance' \
      -F 'maven2.artifactId=mxToMt' \
      -F 'maven2.version=1.0.0' \
      -F 'maven2.asset1=@../transformer-project/many-to-many/Build/mxToMt-1.0.0.jar' \
      -F 'maven2.asset1.extension=jar' \
      -F 'maven2.generate-pom=true'
    sleep 3

    #upload transformer runtime jar into nexus
    echo_header "Start configuring NEXUS with uploading transformer runtime jars"
    curl -u admin:$DEFAULT_PASSWORD -i -X 'POST' \
      'http://nexus3-cicd-utils.'$WILDCARD_DOMAIN'/service/rest/v1/components?repository=maven-releases' \
      -H 'accept: application/json' \
      -H 'Content-Type: multipart/form-data' \
      -F 'maven2.groupId=com.tracegroup.transformer' \
      -F 'maven2.artifactId=transformer-runtime-skinny' \
      -F 'maven2.version=3.8.2' \
      -F 'maven2.asset1=@templates/runtime-jars/transformer-runtime-skinny-3.8.2.jar' \
      -F 'maven2.asset1.extension=jar' \
      -F 'maven2.generate-pom=true'
    sleep 3
    curl -u admin:$DEFAULT_PASSWORD -i -X 'POST' \
      'http://nexus3-cicd-utils.'$WILDCARD_DOMAIN'/service/rest/v1/components?repository=maven-releases' \
      -H 'accept: application/json' \
      -H 'Content-Type: multipart/form-data' \
      -F 'maven2.groupId=com.tracegroup.transformer' \
      -F 'maven2.artifactId=currencylib' \
      -F 'maven2.version=1.0.14' \
      -F 'maven2.asset1=@templates/runtime-jars/currencylib-1.0.14.jar' \
      -F 'maven2.asset1.extension=jar' \
      -F 'maven2.generate-pom=true'
    sleep 3  
  fi  

#Provisioning IBM MQ in swift-sit project
  echo_header "Start installing IBM MQ in project swift-sit"
  oc new-project swift-sit
  oc new-app --docker-image=quay.io/cytan/ibmmq --env LICENSE=accept --env MQ_QMGR_NAME=QM1 --as-deployment-config=true -n swift-sit
  oc rollout pause dc/ibmmq -n swift-sit
  oc create -f templates/ibmmq/ibm-mq-data-pvc.yaml -n swift-sit
  sleep 3
  oc set volume dc/ibmmq --add --name=data --type=persistentVolumeClaim --claim-name=ibm-mq-data --mount-path=/var/mqm -n swift-sit
  oc rollout resume dc/ibmmq -n swift-sit
  oc rollout latest dc/ibmmq -n swift-sit
  oc rollout status dc/ibmmq -n swift-sit
  oc create route passthrough --service=ibmmq --port=9443 -n swift-sit
}

#echo "function echo_header"
function echo_header() {
  echo
  echo "########################################################################"
  echo $1
  echo "########################################################################"
}

################################################################################
# MAIN: DEPLOY DEMO                                                            #
################################################################################

if [ -z "$LOGGEDIN_USER" ]; then
    echo "Please login into your OpenShift"
    exit 255;
fi

START=`date +%s`

echo_header "OpenShift SWIFT Integration Demo ($(date))"
echo "Deploying demo..."
deploy
echo
echo "Provisioning completed successfully!"

END=`date +%s`
echo "(Completed in $(( ($END - $START)/60 )) min $(( ($END - $START)%60 )) sec)"
echo 
