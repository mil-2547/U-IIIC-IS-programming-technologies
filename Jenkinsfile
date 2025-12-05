pipeline {
    agent {
        docker {
            image 'mingw-w64:latest'
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
                    pacman -Syu --noconfirm
                    pacman -S --noconfirm \
                        mingw-w64-x86_64-toolchain \
                        make
                '''
            }
        }

        stage('Test') {
            steps {
                sh 'mingw32-make build-unit'
            }
        }

        stage('Build') {
            steps {
                sh 'mingw32-make build'
            }
        }

        stage('Archive') {
            steps {
                archiveArtifacts artifacts: 'build/bin/*', fingerprint: true
            }
        }
    }
}
