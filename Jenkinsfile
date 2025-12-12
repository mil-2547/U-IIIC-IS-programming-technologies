pipeline {
    agent {
        docker {
            image 'alpine:latest'
			args '-u root:root -v /var/run/docker.sock:/var/run/docker.sock'
        }
    }

	triggers {
		cron('* * * * *')      // Періодично
		
        pollSCM('H/10 * * * *') // Опитування SCM
    }


	environment {
        DOCKER_IMAGE = 'artiprice/l4-jj'
		DOCKER_CREDS_ID = 'dockerhub-creds'
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

        stage('Build test binaries') {
            steps {
                sh 'make build-unit'
			}
        }
		
        stage('Test') {
            steps {

				sh 'make run-unit'
            }
			post {
				always {
					junit 'build/test-results/unit.xml'
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
		
		stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t ${DOCKER_IMAGE}:${BUILD_NUMBER} ."
					sh "docker build -t ${DOCKER_IMAGE}:latest"
                }
            }
        }
		
		stage('Push to Docker Hub') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: DOCKER_CREDS_ID, passwordVariable: 'DOCKER_PASS', usernameVariable: 'DOCKER_USER')]) {
                        sh "echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin"
                        sh "docker push ${DOCKER_IMAGE}:${BUILD_NUMBER}"
                        sh "docker push ${DOCKER_IMAGE}:latest"
                    }
                }
            }
        }
		
		stage('Cleanup') {
             steps {
                 sh "docker rmi ${DOCKER_IMAGE}:${BUILD_NUMBER} || true"
                 sh "docker rmi ${DOCKER_IMAGE}:latest || true"
             }
        }
    }
}
