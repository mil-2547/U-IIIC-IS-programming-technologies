FROM jenkins/jenkins:lts
USER root
RUN apt-get update && apt-get install -y \
    apt-transport-https \
    ca-certificates curl gnupg2 \
    lsb-release

RUN mkdir -p /etc/apt/keyrings && \
     curl -fsSL https://download.docker.com/linux/debian/gpg | \
     gpg --dearmor -o /etc/apt/keyrings/docker.gpg

RUN echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.gpg] \
    https://download.docker.com/linux/debian $(lsb_release -cs) stable" \
    > /etc/apt/sources.list.d/docker.list

RUN apt-get update && apt-get install -y docker-ce-cli

USER jenkins
RUN jenkins-plugin-cli
