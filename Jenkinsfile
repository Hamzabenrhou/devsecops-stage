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
                          -Dsonar.login=sqp_7ff50459db3769b7bae7b2c9397b6aee00986857"

                  }
              }
    }
}