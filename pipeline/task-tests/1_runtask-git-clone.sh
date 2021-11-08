echo $1
#tkn ct start git-clone --param url=$1 --param deleteExisting=true --workspace name=output,claimName=working-pvc --showlog
tkn ct start git-clone --param url='http://gitea.apps.cluster-daea.daea.sandbox1287.opentlc.com/mpua/quarkus-podname.git' --param deleteExisting=true --workspace name=output,claimName=working-pvc --showlog