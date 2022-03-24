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
  
  echo
  echo_header "Manual setup your quay secret to push images..."

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
  oc apply -f pipeline/triggers/
  sleep 10
  oc expose svc el-quarkus-podname-el

exit 0

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

echo_header "OpenShift Pipelines & GitOps Demo ($(date))"
echo "Deploying demo..."
deploy
echo
echo "Provisioning completed successfully!"

END=`date +%s`
echo "(Completed in $(( ($END - $START)/60 )) min $(( ($END - $START)%60 )) sec)"
echo 
