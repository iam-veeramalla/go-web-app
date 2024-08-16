pipeline {
    agent any

   tools {
       go 'go-1.22.5'
    }


    environment {

        SCANNER_HOME = tool 'sonar-scanner'
        SONAR_TOKEN = credentials('sonar-cred')

        }

     stages {

        stage('Build'){
                steps{
                    sh "go build -o go-web-app"
                }
        }

        stage('Unit Test') {
            steps {
                sh "go test ./..."
            }
        }

       stage('Run SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonar'){
                        sh "${SCANNER_HOME}/bin/sonar-scanner -Dsonar.projectKey=gowebapp -Dsonar.projectName=gowebapp"
                }
                
            }
        }

        stage('Docker Build & Tag') {
                        steps {

                                script {
                                        withDockerRegistry(credentialsId: 'docker-cred', toolName: 'docker') 
                                        {
                                                sh 'docker build -t vinay7944/go-web-app:v1 .'
                                        }
                                }
                        }
                }

        stage('Docker Push image'){
                        steps{
                                script{
                                        withDockerRegistry(credentialsId: 'docker-cred',toolName: 'docker'){
                                                sh "docker push vinay7944/go-web-app:v1"
                                        } 
                                }
                        }
                }

        // stage('Docker deploy to local'){
        //                 steps{
        //                     script{
        //                         withDockerRegistry(credentialsId: 'docker-cred',toolName: 'docker'){
        //                                 sh "docker run -d -p 3000:3000 --name gowebapp vinay7944/go-web-app:latest"
        //                         }
        //                     }
        //                 }
        //         }       


     }

        post{
            always{
                    echo "complete"
            }
        }
}
