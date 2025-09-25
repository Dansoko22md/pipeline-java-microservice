pipeline {
    agent any

    environment {
        DB_URL = "jdbc:postgresql://ep-square-glade-a5410wve-pooler.us-east-2.aws.neon.tech/project_db?sslmode=require&channel_binding=require"
        FRONTEND_URL = "https://comfy-conkies-2fcdf3.netlify.app/"
    }

    stages {
        stage('Cloner le code') {
            steps {
                git branch: 'main', url: 'https://github.com/Dansoko22md/pipeline-java-microservice.git'
            }
        }

        stage('Installer dépendances') {
            steps {
                withCredentials([usernamePassword(credentialsId: '71e10545-28cf-4f86-a0a5-71b66481e706', usernameVariable: 'DB_USERNAME', passwordVariable: 'DB_PASSWORD')]) {
                    sh 'mvn clean install -DskipTests'
                }
            }
        }

        stage('Tests') {
            steps {
                withCredentials([usernamePassword(credentialsId: '71e10545-28cf-4f86-a0a5-71b66481e706', usernameVariable: 'DB_USERNAME', passwordVariable: 'DB_PASSWORD')]) {
                    sh 'mvn test'
                }
            }
        }

        stage('Build') {
            steps {
                withCredentials([usernamePassword(credentialsId: '71e10545-28cf-4f86-a0a5-71b66481e706', usernameVariable: 'DB_USERNAME', passwordVariable: 'DB_PASSWORD')]) {
                    sh 'mvn package -DskipTests'
                }
            }
        }

        stage('Déploiement') {
            steps {
                withCredentials([usernamePassword(credentialsId: '71e10545-28cf-4f86-a0a5-71b66481e706', usernameVariable: 'DB_USERNAME', passwordVariable: 'DB_PASSWORD')]) {
                    sh 'java -jar target/*.jar'
                }
            }
        }
    }
}
