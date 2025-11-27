pipeline {
    agent any
    tools {
        jdk 'jdk21'
        nodejs 'node21'
    }
    environment {
        SCANNER_HOME=tool 'sonar-scanner'
        App_Name     = "zomato-app"
        Version      = "v1.0.${BUILD_NUMBER}"
        Docker_User  = "sampathkarra"
        Image_Name   = "${Docker_User}/${App_Name}"
        Image_Tag    = "${Version}"
        Container_Name = "zomato"
        Git_Repo     = "https://github.com/Sampath513/DevOps-Project-Zomato-Kastro.git"
    }
    stages {
        stage ("clean workspace") {
            steps {
                cleanWs()
            }
        }
        stage ("clean Artifacts") {
            steps {
                sh"""
                 docker stop ${Container_Name} || true
                 docker rm ${Container_Name} || true
                 docker rmi ${Image_Name} || true
                 docker rmi ${Image_Name}:latest || true
                 """
            }
        }
        stage ("Git Checkout") {
            steps {
                git credentialsId: 'git-cred', url: "${Git_Repo}"
            }
        }
        stage("Sonarqube Analysis"){
            steps{
                withSonarQubeEnv('sonar-server') {
                    sh ''' $SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=zomato \
                    -Dsonar.projectKey=zomato '''
                }
            }
        }
        stage("Code Quality Gate"){
           steps {
                script {
                    waitForQualityGate abortPipeline: false, credentialsId: 'sonar-token' 
                }
            } 
        }
        stage("Install NPM Dependencies") {
            steps {
                sh "npm install"
            }
        }
        stage ("Trivy File Scan") {
            steps {
                sh "trivy fs . > trivy.txt"
            }
        }
        stage ("Build Docker Image") {
            steps {
                script {
                    sh """
                        docker build -t ${Image_Name}:${Image_Tag} .
                        docker tag ${Image_Name}:${Image_Tag} ${Image_Name}:latest
                    """
                }
            }
        }
        stage ("Tag & Push to DockerHub") {
            steps {
                script {
                    withDockerRegistry(credentialsId: 'docker-cred') {
                       sh """
                        docker push ${Image_Name}:${Image_Tag}
                        docker push ${Image_Name}:latest 
                          """
                    }
                }
            }
        }
 /*       stage('Docker Scout Image') {
            steps {
                script{
                   withDockerRegistry(credentialsId: 'docker', toolName: 'docker'){
                       sh 'docker-scout quickview kastrov/zomato:latest'
                       sh 'docker-scout cves kastrov/zomato:latest'
                       sh 'docker-scout recommendations kastrov/zomato:latest'
                   }
                }
            }
        } */
        
        stage ("Deploy to Container") {
            steps {
                sh 'docker run -d --name ${Container_Name} -p 3000:3000 ${Image_Name}:latest'
            }
        }
        stage ("Update GitOps Repository") {
            steps {
                script {
                    // Clone the GitOps repository
                   withCredentials([string(credentialsId: 'git-cred', variable: 'Git_Token')]) {
                    // Update the image tag in Kubernetes manifests
                    sh """
                        # Update deployment.yaml with new image tag
                        sed -i 's|image:.*|image: ${Image_Name}:${Image_Tag}|' Kubernetes/deployment.yaml
                        
                        # Commit and push changes
                        git config user.name "Sampath513"
                        git config user.email "sampathreddykarra513@gmail.com"
                        git add Kubernetes/deployment.yaml
                        git commit -m "Deploy new version: ${Image_Tag}"
                        git push https://${Git_Token}@github.com/Sampath513/DevOps-Project-Zomato-Kastro.git
                    """
                   }
                }
            }
        }
    }
    post {
    always {
        emailext attachLog: true,
            subject: "'${currentBuild.result}'",
            body: """
                <html>
                <body>
                    <div style="background-color: #FFA07A; padding: 10px; margin-bottom: 10px;">
                        <p style="color: white; font-weight: bold;">Project: ${env.JOB_NAME}</p>
                    </div>
                    <div style="background-color: #90EE90; padding: 10px; margin-bottom: 10px;">
                        <p style="color: white; font-weight: bold;">Build Number: ${env.BUILD_NUMBER}</p>
                    </div>
                    <div style="background-color: #87CEEB; padding: 10px; margin-bottom: 10px;">
                        <p style="color: white; font-weight: bold;">URL: ${env.BUILD_URL}</p>
                    </div>
                </body>
                </html>
            """,
            to: 'sampathreddykarra513@gmail.com',
            mimeType: 'text/html',
            attachmentsPattern: 'trivy.txt'
        }
    }
}
