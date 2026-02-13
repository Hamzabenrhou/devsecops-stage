//@Library('slack') _

pipeline {
  agent any

  environment {
      NVD_API_KEY = ''
      SONAR_TOKEN = ''
      deploymentName = "devsecops"
      containerName = "devsecops-container"
      serviceName = "devsecops-svc"
      imageName = "hamzabenrhouma/numeric-app:${GIT_COMMIT}"
      applicationURL = "http://104.197.188.180"
      applicationURI = "/increment/99"

    }


  stages {
      stage('Fetch Vault Secret') {
                  steps {
                      withVault(
                          configuration: [
                              vaultUrl: 'https://104.197.188.180:8200',
                              vaultCredentialId: 'vault-jenkins-approle',
                              skipSslVerification: true,
                              prefixPath: 'secret'  // ← This is the key fix for KV v2 mount
                          ],
                          vaultSecrets: [
                              [
                                  path: 'jenkins/test',  // relative to prefixPath
                                  engineVersion: 2,
                                  secretValues: [
                                      [vaultKey: 'my-api-key', envVar: 'MY_SECRET']
                                  ]
                              ]
                          ]
                      ) {
                          sh '''
                              echo "Secret from Vault (masked): $MY_SECRET"
                          '''
                      }
                  }
              }
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

stage('SonarQube Analysis') {
    steps {
        withVault(
            configuration: [
                vaultUrl: 'https://104.197.188.180:8200',
                vaultCredentialId: 'vault-jenkins-approle',
                skipSslVerification: true,
                prefixPath: 'secret'
            ],
            vaultSecrets: [
                [path: 'jenkins/sonarqube',
                 engineVersion: 2,
                 secretValues: [
                     [vaultKey: 'analysis_token', envVar: 'SONAR_TOKEN']
                 ]
                ]
            ]
        ) {
            // Now SONAR_TOKEN is available in this scope
            echo "Sonar token loaded from Vault (length: ${SONAR_TOKEN?.length() ?: 0})"

            withSonarQubeEnv('SonarQube') {
                // Use the token explicitly
                sh 'mvn clean verify sonar:sonar -Dsonar.token=$SONAR_TOKEN -Dsonar.projectKey=pfe'
            }
        }
    }
}


// Optional Quality Gate (can be separate or inside)
stage('Quality Gate') {
    steps {
        timeout(time: 5, unit: 'MINUTES') {
            waitForQualityGate abortPipeline: true
        }
    }
}




 stage('Dependency Check') {
     steps {
         withVault(
             configuration: [
                 vaultUrl: 'https://104.197.188.180:8200',
                 vaultCredentialId: 'vault-jenkins-approle',
                 skipSslVerification: true,
                 prefixPath: 'secret'   // keep if it worked for Sonar
             ],
             vaultSecrets: [
                 [path: 'jenkins/nvd-api-key',  // ← your path
                  engineVersion: 2,
                  secretValues: [
                      [vaultKey: 'NVD_API_KEY', envVar: 'NVD_API_KEY']  // adjust vaultKey if your key name is different
                  ]
                 ]
             ]
         ) {
             echo "NVD API key loaded from Vault (length: ${NVD_API_KEY?.length() ?: 0})"

             // Run the check using the fetched key
             sh 'mvn dependency-check:check -DnvdApiKey=$NVD_API_KEY'
         }
     }

     post {
         always {
             // Publish the HTML/XML report (Dependency-Check plugin required)
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
//               stage('OPA Conftest docker') {
//                                      steps {
//                                        sh 'docker run --rm -v \$(pwd):/project  openpolicyagent/conftest test --policy opa-docker-security.rego Dockerfile '
//
//                                      }
//                                  }
//              stage('Docker Build and Push') {
//                    steps {
//                        withDockerRegistry(credentialsId: 'docker-hub', url: '') {
//                                            sh 'printenv' // For debugging
//                                            sh 'docker build -t ""hamzabenrhouma/numeric-app:$GIT_COMMIT"" .'
//                                            sh 'docker push ""hamzabenrhouma/numeric-app:$GIT_COMMIT""'
//                      }
//                      }
//                   }
//              // SPRING BOOT IMAGE BUILD + PUSH
//              stage('Build & Push Spring Boot Image') {
//                steps {
//
//                    withDockerRegistry(credentialsId: 'docker-hub', url: '') {
//                      sh """
//                        docker build -t hamzabenrhouma/numeric-app:${GIT_COMMIT} .
//                        docker push hamzabenrhouma/numeric-app:${GIT_COMMIT}
//                      """
//
//                  }
//                }
//              }
//
//
//              stage('Build & Push Node.js Image') {
//                steps {
//                  dir('node-app') {
//                    withDockerRegistry(credentialsId: 'docker-hub', url: '') {
//                      sh """
//                        docker build -t hamzabenrhouma/plusone-service:${GIT_COMMIT} .
//                        docker push hamzabenrhouma/plusone-service:${GIT_COMMIT}
//                      """
//                    }
//                  }
//                }
//              }
//
//              stage('kubesec') {
//                                      steps {
//                                        sh "bash kubesec-scan.sh"
//
//                                      }
//                                  }
//              stage('OPA Conftest k8s') {
//                                                   steps {
//                                                     sh 'docker run --rm -v \$(pwd):/project  openpolicyagent/conftest test --policy opa-k8s-security.rego k8s_deployment_service.yaml '
//
//                                                   }
//                                               }
// //               stage('Trivy scan k8s') {
// //                                      steps {
// //                                        sh "bash trivy-k8s.sh"
// //
// //                                      }
// //                                  }
//              stage('Kubernetes Deployment - DEV') {
//                    steps {
//                        withKubeConfig([credentialsId: 'kubeconfig']){
//                        sh "sed -i 's#replace#hamzabenrhouma/numeric-app:${GIT_COMMIT}#g' k8s_deployment_service.yaml"
//                        sh "kubectl apply -f k8s_deployment_service.yaml"
//                      }
//                      }
//                    }
//              stage('Kubernetes Deployment - Node.js') {
//                steps {
//                  withKubeConfig([credentialsId: 'kubeconfig']) {
//                    sh "sed -i 's#latest#${GIT_COMMIT}#g' node-app/node-k8s.yaml"
//                    sh "kubectl apply -f node-app/node-k8s.yaml"
//                  }
//                }
//              }
//
//              stage('Check Rollout Status') {
//                          steps {
//                              withKubeConfig([credentialsId: 'kubeconfig']) {
//                                  sh "kubectl rollout status deployment/devsecops"
//                              }
//                          }
//                      }
//               stage('OWASP-ZAP DAST') {
//                          steps {
//                              withKubeConfig([credentialsId: 'kubeconfig']) {
//                                 withDockerRegistry(credentialsId: 'docker-hub', url: '') {
//                                     sh 'bash zap.sh'
//                                                   }
//                                               }
//                                               }
//                 }
//
//
//
//
//               stage('Kubernetes Deployment prod- DEV') {
//                                 steps {
//                                     withKubeConfig([credentialsId: 'kubeconfig']){
//                                     sh "sed -i 's#replace#hamzabenrhouma/numeric-app:${GIT_COMMIT}#g' k8s-prod-service.yaml"
//                                     sh "kubectl -n prod apply -f k8s-prod-service.yaml"
//                                   }
//                                   }
//                                 }
//               stage('Check Rollout Status prod') {
//                                        steps {
//                                            withKubeConfig([credentialsId: 'kubeconfig']) {
//                                                sh "kubectl -n prod rollout status deployment/devsecops"
//                                            }
//                                        }
                                    }
               }

//   post{
//     always{
//         publishHTML([allowMissing: false, alwaysLinkToLastBuild: true, icon: '', keepAll: true, reportDir: 'owasp-zap-report', reportFiles: 'zap_report.html', reportName: 'OWASP ZAP HTML Report', reportTitles: 'OWASP ZAP HTML Report', useWrapperFileDirectly: true])
//         sendNotifications currentBuild.result
//     }
//     }
//
//

//
//
//              }




