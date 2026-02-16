//@Library('slack') _

pipeline {
  agent any

  environment {
      NVD_API_KEY = ''
      SONAR_TOKEN = ''
      deploymentName = "devsecops"
      containerName = "devsecops-container"
      serviceName = "devsecops-svc"
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
             sh 'mvn org.owasp:dependency-check-maven:12.2.0:check -DnvdApiKey=$NVD_API_KEY -U'
         }
     }

     post {
         always {
             // Publish the HTML/XML report (Dependency-Check plugin required)
             dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'
         }
     }
 }
             stage('Trivy scan') {
                        steps {
                          sh "bash trivy-docker-image.sh"

                        }
                    }
              stage('Debug Files') {
                  steps {
                      sh 'pwd && ls -l Dockerfile opa-docker-security.rego || echo "Files missing"'
                  }
              }
           stage('OPA Conftest docker') {
               steps {
                   sh 'docker pull openpolicyagent/conftest:latest || true'
                   sh 'docker run --rm openpolicyagent/conftest:latest --version'  // debug: print version

                   sh """
                       docker run --rm \
                           -v "\$(pwd)":/project \
                           openpolicyagent/conftest:v0.58.0 \
                           test --policy opa-docker-security.rego \
                           Dockerfile
                   """
               }
           }
stage('Docker Build and Push') {
    steps {
        withVault(
            configuration: [
                vaultUrl: 'https://104.197.188.180:8200',
                vaultCredentialId: 'vault-jenkins-approle',
                skipSslVerification: true,
                prefixPath: 'secret'
            ],
            vaultSecrets: [
                [path: 'jenkins/dockerhub',
                 engineVersion: 2,
                 secretValues: [
                     [vaultKey: 'username', envVar: 'DOCKER_USERNAME'],
                     [vaultKey: 'access_token', envVar: 'DOCKER_PASSWORD']
                 ]
                ]
            ]
        ) {
            // Debug (optional - remove later)
            sh 'echo "Docker credentials loaded from Vault"'

            // Login to Docker Hub
            sh '''
                echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
            '''

            // Build and push
            sh '''
                docker build -t ham02br26/numeric-app:${GIT_COMMIT} .
                docker push ham02br26/numeric-app:${GIT_COMMIT}
            '''
        }
    }
}

// For Spring Boot image (same pattern)
stage('Build & Push Spring Boot Image') {
    steps {
        withVault(
            configuration: [
                vaultUrl: 'https://104.197.188.180:8200',
                vaultCredentialId: 'vault-jenkins-approle',
                skipSslVerification: true,
                prefixPath: 'secret'
            ],
            vaultSecrets: [
                [path: 'jenkins/dockerhub',
                 engineVersion: 2,
                 secretValues: [
                     [vaultKey: 'username', envVar: 'DOCKER_USERNAME'],
                     [vaultKey: 'access_token', envVar: 'DOCKER_PASSWORD']
                 ]
                ]
            ]
        ) {
            sh '''
                echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
                docker build -t ham02br26/numeric-app:${GIT_COMMIT} .
                docker push ham02br26/numeric-app:${GIT_COMMIT}
            '''
        }
    }
}

// For Node.js image (same)
stage('Build & Push Node.js Image') {
    steps {
        dir('node-app') {
            withVault(
                configuration: [
                    vaultUrl: 'https://104.197.188.180:8200',
                    vaultCredentialId: 'vault-jenkins-approle',
                    skipSslVerification: true,
                    prefixPath: 'secret'
                ],
                vaultSecrets: [
                    [path: 'jenkins/dockerhub',
                     engineVersion: 2,
                     secretValues: [
                         [vaultKey: 'username', envVar: 'DOCKER_USERNAME'],
                         [vaultKey: 'access_token', envVar: 'DOCKER_PASSWORD']
                     ]
                    ]
                ]
            ) {
                sh '''
                    echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
                    docker build -t ham02br26/plusone-service:${GIT_COMMIT} .
                    docker push ham02br26/plusone-service:${GIT_COMMIT}
                '''
            }
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
                                                     sh 'docker pull openpolicyagent/conftest:latest || true'
                                                                       sh 'docker run --rm openpolicyagent/conftest:latest --version'  // debug: print version

                                                     sh """
                                                                           docker run --rm \
                                                                               -v "\$(pwd)":/project \
                                                                               openpolicyagent/conftest:v0.58.0 \
                                                                               test --policy opa-k8s-security.rego \
                                                                               k8s_deployment_service.yaml
                                                                       """

                                                  }
                                              }
              stage('Trivy scan k8s') {
                                     steps {
                                       sh "bash trivy-k8s.sh"

                                     }
                                 }
stage('Kubernetes Deployment - DEV') {
                  steps {
                      withVault(
                          configuration: [
                              vaultUrl: 'https://104.197.188.180:8200',
                              vaultCredentialId: 'vault-jenkins-approle',
                              skipSslVerification: true,
                              prefixPath: 'secret'
                          ],
                          vaultSecrets: [
                              [path: 'jenkins/kubernetes',
                               engineVersion: 2,
                               secretValues: [
                                   [vaultKey: 'kubeconfig', envVar: 'KUBECONFIG_CONTENT']
                               ]
                              ]
                          ]
                      ) {
                          // Create kubeconfig file from Vault secret
                          sh '''
                              mkdir -p ~/.kube
                              echo "$KUBECONFIG_CONTENT" > ~/.kube/config
                              chmod 600 ~/.kube/config
                          '''

                          // Deploy to DEV namespace
                          sh """
                              sed -i 's#replace#ham02br26/numeric-app:${GIT_COMMIT}#g' k8s_deployment_service.yaml
                              kubectl apply -f k8s_deployment_service.yaml --namespace=default
                          """
                      }
                  }
              }

              stage('Kubernetes Deployment - Node.js') {
                  steps {
                      dir('node-app') {
                          withVault(
                              configuration: [
                                  vaultUrl: 'https://104.197.188.180:8200',
                                  vaultCredentialId: 'vault-jenkins-approle',
                                  skipSslVerification: true,
                                  prefixPath: 'secret'
                              ],
                              vaultSecrets: [
                                  [path: 'jenkins/kubernetes',
                                   engineVersion: 2,
                                   secretValues: [
                                       [vaultKey: 'kubeconfig', envVar: 'KUBECONFIG_CONTENT']
                                   ]
                                  ]
                              ]
                          ) {
                              sh '''
                                  mkdir -p ~/.kube
                                  echo "$KUBECONFIG_CONTENT" > ~/.kube/config
                                  chmod 600 ~/.kube/config
                              '''

                              sh """
                                  sed -i 's#latest#${GIT_COMMIT}#g' node-k8s.yaml
                                  kubectl apply -f node-k8s.yaml --namespace=default
                              """
                          }
                      }
                  }
              }

              stage('Check Rollout Status') {
                  steps {
                      withVault(
                          configuration: [
                              vaultUrl: 'https://104.197.188.180:8200',
                              vaultCredentialId: 'vault-jenkins-approle',
                              skipSslVerification: true,
                              prefixPath: 'secret'
                          ],
                          vaultSecrets: [
                              [path: 'jenkins/kubernetes',
                               engineVersion: 2,
                               secretValues: [
                                   [vaultKey: 'kubeconfig', envVar: 'KUBECONFIG_CONTENT']
                               ]
                              ]
                          ]
                      ) {
                          sh '''
                              mkdir -p ~/.kube
                              echo "$KUBECONFIG_CONTENT" > ~/.kube/config
                              chmod 600 ~/.kube/config
                              kubectl rollout status deployment/devsecops --namespace=default
                          '''
                      }
                  }
              }

stage('OWASP-ZAP DAST') {
    steps {
        withVault(
            configuration: [
                vaultUrl: 'https://104.197.188.180:8200',
                vaultCredentialId: 'vault-jenkins-approle',
                skipSslVerification: true,
                prefixPath: 'secret'
            ],
            vaultSecrets: [
                [path: 'jenkins/dockerhub',
                 engineVersion: 2,
                 secretValues: [
                     [vaultKey: 'username', envVar: 'DOCKER_USERNAME'],
                     [vaultKey: 'access_token', envVar: 'DOCKER_PASSWORD']
                 ]
                ]
            ]
        ) {
            sh '''
                echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin

                # Pull the ZAP image first
                docker pull zaproxy/zap-weekly:latest

                # Run ZAP scan with environment variables
                export serviceName=${serviceName}
                export applicationURL=${applicationURL}
                export applicationURI=${applicationURI}

                bash zap.sh
            '''
        }
    }
}
}}
  post{
    always{
        publishHTML([allowMissing: false, alwaysLinkToLastBuild: true, icon: '', keepAll: true, reportDir: 'owasp-zap-report', reportFiles: 'zap_report.html', reportName: 'OWASP ZAP HTML Report', reportTitles: 'OWASP ZAP HTML Report', useWrapperFileDirectly: true])
        sendNotifications currentBuild.result
    }
    }

//

//
//
//              }




