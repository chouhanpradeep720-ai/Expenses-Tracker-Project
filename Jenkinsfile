pipeline{
    agent any
    tools {
        maven 'maven-3.9'
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

    }
    
}
        
