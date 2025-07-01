pipeline {
  agent any

  stages {
      stage('Build Artifact') {
            steps {
              sh "mvn clean package -DskipTests=true"
              archive 'target/*.jar'
            }
        }
      stage('SonarQube-SAST') {
                  steps {
                    sh "mvn clean verify sonar:sonar \
                          -Dsonar.projectKey=numeric-application \
                          -Dsonar.host.url=http://devsecops.westeurope.cloudapp.azure.com:30381 \
                          -Dsonar.login=sqp_3f1ec8d71ce5904e7d6ccd3514e71a3d60cfb7b0"

                  }
              }
    }
}