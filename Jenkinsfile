pipeline {
    agent {
        docker {
            image 'alpine:latest'
            args '-u root:root'
        }
    }

    options {
        timestamps()
    }

    stages {
        
        stage('Check SCM') {
            steps {
                checkout scm
            }
        }
        
        stage('Install deps') {
            steps {
                sh '''
                    apk update
                    apk add --no-cache cmake make g++ gcc libc-dev
                '''
            }
        }

	stage('Build vendors') {
	    steps {
			sh 'make vendor-build'
			sh 'ls vendor/fmt/build'
			sh 'ls vendor/gtest/build'
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
