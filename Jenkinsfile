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
                    apk add --no-cache cmake make g++ gcc libc-dev bash
                '''
            }
        }

		stage('Build vendors') {
		    steps {
				sh 'make vendor-build'
				sh 'ls vendors/fmt/build'
				sh 'ls vendors/gtest/build'
		    }
		}


        stage('Test') {
            steps {
                sh 'make build-unit'
				sh 'make run-unit'
            }
			post {
				always {
					junit './build/test-results/unit.xml'
				}
				success {
					echo 'application testing successfully completed'
				}
				failure {
					echo "Oh nooooo!!! Tests failed!"
				}
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
