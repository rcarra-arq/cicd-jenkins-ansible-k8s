pipeline {
    agent any

    environment {
        IMAGE   = 'web-app:v2'
        CLUSTER = 'cicd-lab'
    }

    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/rcarra-arq/cicd-jenkins-ansible-k8s.git',
                    branch: 'main'
            }
        }

        stage('Build') {
            steps {
                sh "docker build -t ${IMAGE} ."
            }
        }

        stage('Load into Kind') {
            steps {
                sh "kind load docker-image ${IMAGE} --name ${CLUSTER}"
            }
        }

        stage('Deploy') {
            steps {
                dir('ansible') {
                    sh 'ansible-playbook deploy.yml'
                }
            }
        }
    }
}
