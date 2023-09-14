FROM jenkins/jenkins:lts

USER root

RUN apt-get update -y 
RUN apt-get install -y --no-install-recommends ca-certificates curl gnupg lsb-release
RUN rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/apt/keyrings 
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

RUN chmod a+r /etc/apt/keyrings/docker.gpg && apt-get -y update
RUN apt-get install -y --no-install-recommends docker-ce docker-ce-cli containerd.io docker-compose-plugin

RUN apt-get install -y --no-install-recommends apt-transport-https
RUN curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - 
RUN echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list 
RUN apt-get -y update 
RUN apt-get install  -y --no-install-recommends kubectl

RUN usermod -a -G docker jenkins

RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 
RUN chmod 700 get_helm.sh 
RUN ./get_helm.sh
RUN rm get_helm.sh

#USER jenkins

ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false
ENV CASC_JENKINS_CONFIG /var/jenkins_home/casc.yaml

RUN jenkins-plugin-cli --plugins "configuration-as-code cloudbees-folder timestamper gradle git ssh-slaves \
github-branch-source ws-cleanup antisamy-markup-formatter build-timeout pipeline-github-lib \
matrix-auth authorize-project credentials-binding pipeline-stage-view pam-auth mailer \
pipeline-milestone-step pipeline-build-step pipeline-model-api pipeline-model-extensions \
workflow-multibranch pipeline-stage-tags-metadata pipeline-model-definition pipeline-stage-step \
pipeline-build-step basic-branch-build-strategies "

COPY config/ /var/jenkins_home/casc.yaml
COPY my_jobs/ /var/jenkins_home/jobs