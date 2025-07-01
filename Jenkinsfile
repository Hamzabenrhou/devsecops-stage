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
                    withSonarQubeEnv('SonarQube'){
                    sh "mvn clean verify sonar:sonar \
                          -Dsonar.projectKey=numeric-application \
                          -Dsonar.host.url=http://devsecops.westeurope.cloudapp.azure.com:30381 \
                          -Dsonar.login=sqp_2647304632e01564cccf09471e4ea55c743b126c"

                  }
                  timeout(time: 2, unit: 'MINUTES') {
                            script{

                                      waitForQualityGate abortPipeline: true
                            }
                  }
              }
              }
      stage('Dependency-check') {
                  steps {
                    sh "mvn dependency-check:check"
                    }
                  post{
                    always{
                        dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'
                    }
                  }

                  }
              }
    }
}