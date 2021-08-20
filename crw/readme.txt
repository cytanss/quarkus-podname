This is to generate the secret with maven repo settings to be used by code ready workspace

Change it to base64
  cat maven-settings.xml| base64

Update into the scret.yaml

Create the scret in same project as the workspace