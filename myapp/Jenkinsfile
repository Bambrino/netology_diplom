#!groovy
pipeline {
    agent {
        label 'built-in'
        }
    triggers { pollSCM('* * * * *') }
    options {
        buildDiscarder(logRotator(numToKeepStr: '10', artifactNumToKeepStr: '10'))
        timestamps()
    }
    environment {
    BUILD_TAG_NAME = '$BUILD_NUMBER'
    IMAGE_BASE = "bambrino/myapp"
    DOCKER_REPO_NAME = 'bambrino'
    IMAGE_NAME = "myapp"
    CHART_NAME = 'myapp-chart'
    }
    stages {
        stage("Docker Login") {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker_hub', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                    sh """
                    docker login -u $USERNAME --password $PASSWORD
                    """
                }
            }
        }
        stage("Create Docker Image") {
            when { triggeredBy 'SCMTrigger' }
            steps {
                dir ('.') {
                	sh """
                    docker build -t $IMAGE_BASE:$BUILD_TAG_NAME .
                    """
                }
            }
        }
        stage("Create Docker Image with Tag") {
            when { buildingTag() }
            steps {
                dir ('.') {
                	sh """
                    docker build -t $IMAGE_BASE:$TAG_NAME .
                    """
                }
            }
        }
        stage("Docker Push") {
            when { triggeredBy 'SCMTrigger' }
            steps {
                sh """
                docker push $IMAGE_BASE:$BUILD_TAG_NAME
                """
            }
        }
        stage("Create Push with Tag") {
            when { buildingTag() }
            steps {
                dir ('.') {
                	sh """
                    docker push $IMAGE_BASE:$TAG_NAME
                    """
                }
            }
        }
        stage("Deploy App") {
            when { buildingTag() }
            steps {
                sh """
                helm upgrade myapp-stage myapp-chart --set image_frontend.tag=$TAG_NAME --install -n stage
                """
            }
        }
    }
    post {
        always {
            cleanWs(cleanWhenNotBuilt: false,
                    deleteDirs: true,
                    disableDeferredWipeout: true,
                    notFailBuild: true,
                    patterns: [[pattern: '.gitignore', type: 'INCLUDE'],
                               [pattern: '.propsfile', type: 'EXCLUDE']])
        }
    }
}