pipeline {
  options { timestamps()}
  agent any
  stages {
    stage('Check scm') {
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
        archiveArtifacts artifacts: 'build/bin/app', fingerprint: true
      }
    }
  }
}
