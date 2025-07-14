@Library('slack') _



pipeline {
  agent any

  environment {
      deploymentName = "devsecops"
      containerName = "devsecops-container"
      serviceName = "devsecops-svc"
      imageName = "hamzabenrhouma/numeric-app:${GIT_COMMIT}"
      applicationURL = "http://devsecops.westeurope.cloudapp.azure.com"
      applicationURI = "/increment/99"
    }


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
  stage('Dependency Check') {
              steps {
                  withCredentials([string(credentialsId: 'nvd-api-key', variable: 'NVD_API_KEY')]) {
                      sh "mvn dependency-check:check -DnvdApiKey=\${NVD_API_KEY}"
                  }
              }
              post {
                  always {
                      dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'
                  }
              }
          }
//              stage('Trivy scan') {
//                         steps {
//                           sh "bash trivy-docker-image.sh"
//
//                         }
//                     }
              stage('OPA Conftest docker') {
                                     steps {
                                       sh 'docker run --rm -v \$(pwd):/project  openpolicyagent/conftest test --policy opa-docker-security.rego Dockerfile '

                                     }
                                 }
             stage('Docker Build and Push') {
                   steps {
                       withDockerRegistry(credentialsId: 'docker-hub', url: '') {
                                           sh 'printenv' // For debugging
                                           sh 'docker build -t ""hamzabenrhouma/numeric-app:$GIT_COMMIT"" .'
                                           sh 'docker push ""hamzabenrhouma/numeric-app:$GIT_COMMIT""'
                     }
                     }
                  }
             stage('kubesec') {
                                     steps {
                                       sh "bash kubesec-scan.sh"

                                     }
                                 }
             stage('OPA Conftest k8s') {
                                                  steps {
                                                    sh 'docker run --rm -v \$(pwd):/project  openpolicyagent/conftest test --policy opa-k8s-security.rego k8s_deployment_service.yaml '

                                                  }
                                              }
//               stage('Trivy scan k8s') {
//                                      steps {
//                                        sh "bash trivy-k8s.sh"
//
//                                      }
//                                  }
             stage('Kubernetes Deployment - DEV') {
                   steps {
                       withKubeConfig([credentialsId: 'kubeconfig']){
                       sh "sed -i 's#replace#hamzabenrhouma/numeric-app:${GIT_COMMIT}#g' k8s_deployment_service.yaml"
                       sh "kubectl apply -f k8s_deployment_service.yaml"
                     }
                     }
                   }
             stage('Check Rollout Status') {
                         steps {
                             withKubeConfig([credentialsId: 'kubeconfig']) {
                                 sh "kubectl rollout status deployment/devsecops"
                             }
                         }
                     }
              stage('OWASP-ZAP DAST') {
                         steps {
                             withKubeConfig([credentialsId: 'kubeconfig']) {
                                withDockerRegistry(credentialsId: 'docker-hub', url: '') {
                                    sh 'bash zap.sh'
                                                  }
                                              }
                                              }
                }




              stage('Kubernetes Deployment prod- DEV') {
                                steps {
                                    withKubeConfig([credentialsId: 'kubeconfig']){
                                    sh "sed -i 's#replace#hamzabenrhouma/numeric-app:${GIT_COMMIT}#g' k8s-prod-service.yaml"
                                    sh "kubectl -n prod apply -f k8s-prod-service.yaml"
                                  }
                                  }
                                }
              stage('Check Rollout Status prod') {
                                       steps {
                                           withKubeConfig([credentialsId: 'kubeconfig']) {
                                               sh "kubectl -n prod rollout status deployment/devsecops"
                                           }
                                       }
                                   }
               }
  post{
    always{
        publishHTML([allowMissing: false, alwaysLinkToLastBuild: true, icon: '', keepAll: true, reportDir: 'owasp-zap-report', reportFiles: 'zap_report.html', reportName: 'OWASP ZAP HTML Report', reportTitles: 'OWASP ZAP HTML Report', useWrapperFileDirectly: true])
        sendNotifications currentBuild.result
    }
    }





             }




