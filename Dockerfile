####
# This Dockerfile is used in order to build a container that runs the Quarkus application in JVM mode
#
# Before building the container image run:
#
# ./mvnw package
#
# Then, build the image with:
#
# docker build -f src/main/docker/Dockerfile.jvm -t quarkus/quarkus-podname-jvm .
#
# Then run the container using:
#
# docker run -i --rm -p 8080:8080 quarkus/quarkus-podname-jvm
#
# If you want to include the debug port into your docker image
# you will have to expose the debug port (default 5005) like this :  EXPOSE 8080 5050
#
# Then run the container using :
#
# docker run -i --rm -p 8080:8080 -p 5005:5005 -e JAVA_ENABLE_DEBUG="true" quarkus/quarkus-podname-jvm
#
###
#FROM registry.access.redhat.com/ubi8/ubi-minimal:8.3
FROM registry.access.redhat.com/ubi8/ubi-minimal:latest 

ARG JAVA_PACKAGE=java-17-openjdk-headless
ARG RUN_JAVA_VERSION=1.3.8
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en'
# Install java and the run-java script
# Also set up permissions for user `1001`
RUN microdnf install curl ca-certificates ${JAVA_PACKAGE} \
    && microdnf update \
    && microdnf clean all \
    && mkdir /home/deployments \
    && chown 185 /home/deployments \
    && chmod "g+rwX" /home/deployments \
    && chown 185:root /home/deployments \
    && curl https://repo1.maven.org/maven2/io/fabric8/run-java-sh/${RUN_JAVA_VERSION}/run-java-sh-${RUN_JAVA_VERSION}-sh.sh -o /home/deployments/run-java.sh \
    && chown 185 /home/deployments/run-java.sh \
    && chmod 540 /home/deployments/run-java.sh \
    && echo "securerandom.source=file:/dev/urandom" >> /etc/alternatives/jre/lib/security/java.security

# Configure the JAVA_OPTIONS, you can add -XshowSettings:vm to also display the heap size.
ENV JAVA_OPTIONS="-Dquarkus.http.host=0.0.0.0 -Djava.util.logging.manager=org.jboss.logmanager.LogManager"
# We make four distinct layers so if there are application changes the library layers can be re-used
COPY --chown=185 target/quarkus-app/lib/ /home/deployments/lib/
COPY --chown=185 target/quarkus-app/*.jar /home/deployments/
COPY --chown=185 target/quarkus-app/app/ /home/deployments/app/
COPY --chown=185 target/quarkus-app/quarkus/ /home/deployments/quarkus/

EXPOSE 8080
USER 185

ENTRYPOINT [ "/home/deployments/run-java.sh" ]
