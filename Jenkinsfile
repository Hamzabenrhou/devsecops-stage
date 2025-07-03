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
                          -Dsonar.host.url=http://devsecops.westeurope.cloudapp.azure.com:9000 \
                          -Dsonar.login=sqp_b19a25b1a74f39b82f243e8acd5612192da50f1e"

                  }
                  timeout(time: 2, unit: 'MINUTES') {
                            script{

                                      waitForQualityGate abortPipeline: true
                            }
                  }
              }
              }
//       stage('Dependency-check') {
//                   steps {
//                     sh "mvn dependency-check:check"
//                     }
//                   post{
//                     always{
//                         dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'
//                     }
//
//
//
//                   }
//               }
             stage('Trivy scan') {
                        steps {
                          sh "bash trivy-docker-image.sh"

                        }
                    }


    }
}