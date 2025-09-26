pipeline {
    agent any

    environment {
        DB_USERNAME   = credentials('DB_USERNAME')
        DB_PASSWORD   = credentials('DB_PASSWORD')
        DB_URL        = credentials('DB_URL')
        FRONTEND_URL  = credentials('FRONTEND_URL')
        DOCKERHUB_CREDENTIALS = 'dockerhub-credentials-id' // tes credentials Jenkins pour Docker Hub
        IMAGE_NAME    = 'moise25/monmicroservice'           // change avec ton nom d'image
        IMAGE_TAG     = 'latest'
    }

    stages {
        stage('Clone') {
            steps {
                git branch: 'main', url: 'https://github.com/Dansoko22md/pipeline-java-microservice.git'
            }
        }

        stage('Install Dependencies') {
            steps {
                sh 'mvn clean install -DskipTests'
            }
        }

        stage('Tests') {
            steps {
                sh 'mvn test'
            }
        }

        stage('Build') {
            steps {
                sh 'mvn package -DskipTests'
            }
        }

        stage('Docker Build & Push') {
            steps {
                script {
                    // Login Docker
                    withCredentials([usernamePassword(credentialsId: "${DOCKERHUB_CREDENTIALS}", usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                    }

                    // Build l'image Docker
                    sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."

                    // Push l'image vers le registry
                    sh "docker push ${IMAGE_NAME}:${IMAGE_TAG}"
                }
            }
        }

        stage('Deploy') {
            steps {
                echo "Déploiement en cours..."
                // Ici tu peux ajouter le déploiement avec Docker run, Kubernetes, ou un autre outil
            }
        }
    }
}
