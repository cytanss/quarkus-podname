#oc create sa build-bot
oc patch serviceaccount pipeline  -p '{"secrets": [{"name": "redhat-pull-secret"}]}'