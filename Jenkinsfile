pipeline {
  agent any

  stages {
      stage('Build Artifact') {
            steps {
              sh "mvn clean package -DskipTests=true"
              archive 'target/*.jar'
            }
        }
      stage('SCM') {
                  steps {
                      checkout scm
                  }
              }
              stage('SonarQube Analysis') {
                  steps {
                      withSonarQubeEnv('SonarQube') { // Matches the SonarQube server name in Jenkins config
                          withCredentials([string(credentialsId: 'sonarqube-token', variable: 'SONAR_TOKEN')]) {
                              sh '''
                              mvn clean verify sonar:sonar \
                                  -Dsonar.projectKey=numeric-application \
                                  -Dsonar.host.url=http://devsecops.westeurope.cloudapp.azure.com:30381 \
                                  -Dsonar.login=$SONAR_TOKEN
                              '''
                          }
                      }
    }
}