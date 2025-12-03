pipeline {
    agent {
        docker {
            image 'ubuntu:latest'
            args '-u root:root'
        }
    }

    options {
        timestamps()
    }

    stages {
        stage('Install deps') {
            steps {
                sh '''
                    apt-get update
                    apt-get install -y make gcc
                '''
            }
        }

        stage('Check SCM') {
            steps {
                checkout scm
            }
        }

        stage('Test') {
            steps {
                sh 'make build-unit'
            }
        }

        stage('Build') {
            steps {
                sh 'make build'
            }
        }

        stage('Archive') {
            steps {
                archiveArtifacts artifacts: 'build/bin/app', fingerprint: true
            }
        }
    }
}
