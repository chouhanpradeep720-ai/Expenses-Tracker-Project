pipeline{
    agent any
    tools {
        maven 'maven-3.9'
    }
    environment {
        DOCKERHUB_CREDENTIALS = credentials('docker-id')
        DOCKER_IMAGE = "pradeepchouhan115/docker.repo:expenses-tracker.${BUILD_NUMBER}"
    }
        
    stages{
        stage('Checkout Git Code') {
            steps {
                script {
                    git branch: 'dev',   
                    credentialsId: 'git-hub-id', 
                    url: 'https://github.com/chouhanpradeep720-ai/Expenses-Tracker-Project.git'
                }
            }
        }
        //stage('Build with Maven') {
           // steps {
             //   script {
               //     sh 'mvn clean package -DskipTests'
                //}
            //}
        //} withSonarQubeEnv( ' SonarQube' )

        stage('Build Project and Check Quality with SonarQube') {
            steps {
                script {
                    withSonarQubeEnv(installationName: ' SonarQube', credentialsId: 'sonarqubeid') {
                        sh 'mvn clean package sonar:sonar'
                    }
                }
            }
        }


        stage("Quality Gate") {
            steps {
                script {
                     timeout(time: 1, unit: 'HOURS') {
                        def qg = waitForQualityGate()
                        if (qg.status != 'OK') {
                          error "Pipeline aborted due to quality gate failure: ${qg.status}"
                        }
                    }
                }
            }
        }

        stage ('Build Images and Push to Docker Hub'){
            steps {
                script {
                    sh "docker build -t ${DOCKER_IMAGE} . "
                    sh 'docker login -u ${DOCKERHUB_CREDENTIALS_USR} -p ${DOCKERHUB_CREDENTIALS_PSW} '
                    sh "docker push ${DOCKER_IMAGE} "
                }
            }        
        }
        stage('Clean Docker Images'){
            steps {
                script {
                    sh "docker rmi ${DOCKER_IMAGE}"
                }
            }
        }
        stage('Clean Workspace') {
            steps {
                cleanWs()
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    def KUBE_IMAGE = env.DOCKER_IMAGE
                    withCredentials([sshUserPrivateKey(credentialsId: 'ssh-key-id', 
                    keyFileVariable: 'SSH_KEY', 
                    usernameVariable: 'SSH_USER')]) {

                    sshCommand remote: [
                    name: 'Kubernetes-Server',    
                    host: '10.160.198.235' ,   
                    user: SSH_USER,
                    identityFile: SSH_KEY ,
                    allowAnyHosts: true

                    ], 
                    command: """
                         cd /home/pradeep-ubuntu
                         # repo exits or not
                            if [ -d "Expenses-Tracker-Project" ]; then
                                cd Expenses-Tracker-Project
                                git pull origin dev
                            else
                                 git clone -b dev https://github.com/chouhanpradeep720-ai/Expenses-Tracker-Project.git
                                 cd Expenses-Tracker-Project
                            fi
                            echo "Deploying image: ${KUBE_IMAGE}"
                            pwd
                            cd Kubernets
                            IMAGE_NAME="${KUBE_IMAGE}" envsubst < tracker-deployment.yaml | kubectl apply -f -

                            for file in \$( find . -name "*.yaml"  ! -name "tracker-deployment.yaml" ); 
                            do
                                kubectl apply -f "\$file"
                            done    
                            kubectl get pods 
                         """       
                    }                      
                }           
            }
        }   
    }
}
        
