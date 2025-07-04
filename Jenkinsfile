pipeline {
  agent any

  stages {
      stage('Build Artifact') {
            steps {
              sh "mvn clean package -DskipTests=true"
              archive 'target/*.jar'
            }
        }
          stage('Unit Tests - JUnit and JaCoCo') {
              steps {
                sh "mvn test"
              }
            }

            stage('Mutation Tests - PIT') {
              steps {
                sh "mvn org.pitest:pitest-maven:mutationCoverage"
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
             stage('Docker Build and Push') {
                   steps {
                       withDockerRegistry(credentialsId: 'docker-hub', url: 'https://index.docker.io/v1/') {
                                           sh 'printenv' // Keep for debugging
                                           sh "docker build -t ${DOCKER_IMAGE} ."
                                           sh "docker push ${DOCKER_IMAGE}"
                     }
                  }
//              stage('Kubernetes Deployment - DEV') {
//                    steps {
//                        sh "sed -i 's#REPLACE_ME#docker-registry:5000/java-app:latest#g' k8s_deployment_service.yaml"
//                        sh "kubectl apply -f k8s_deployment_service.yaml"
//                      }
//                    }
//
//
//                }
//
//                post {
//                  always {
//                    pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
//                    dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'
//                  }
//
               }

             }




