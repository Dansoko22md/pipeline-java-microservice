pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = 'dockerhub-credentials-id'
        IMAGE_NAME    = 'moise25/monmicroservice'
        IMAGE_TAG     = "${env.BUILD_NUMBER}" // Tag unique par build
        K8S_NAMESPACE = 'devops'
    }

    stages {
        stage('Checkout Code') {
            steps {
                echo "========================================="
                echo "STAGE 1 : Checkout du code source"
                echo "========================================="

                git branch: 'main',
                    url: 'https://github.com/Dansoko22md/pipeline-java-microservice.git'

                echo "✅ Code récupéré avec succès depuis Git"
            }
        }

        stage('Build avec Maven') {
            steps {
                echo "========================================="
                echo "STAGE 2 : Build du projet avec Maven"
                echo "========================================="

                sh 'mvn clean install -DskipTests'
                sh 'mvn package -DskipTests'

                echo "✅ Build Maven terminé avec succès"
            }
        }

        stage('Build & Push Docker Image') {
            steps {
                echo "========================================="
                echo "STAGE 3 : Build et Push de l'image Docker"
                echo "========================================="

                script {
                    withCredentials([usernamePassword(
                        credentialsId: "${DOCKERHUB_CREDENTIALS}",
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASS'
                    )]) {
                        sh '''
                            echo "🔐 Connexion à Docker Hub..."
                            echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                        '''
                    }

                    // Build avec les deux tags : numéro de build ET latest
                    sh """
                        echo "🐳 Construction de l'image Docker..."
                        docker build -t ${IMAGE_NAME}:${IMAGE_TAG} -t ${IMAGE_NAME}:latest .
                        echo "✅ Image construite : ${IMAGE_NAME}:${IMAGE_TAG}"
                    """

                    // Push des deux tags
                    sh """
                        echo "📤 Push des images vers Docker Hub..."
                        docker push ${IMAGE_NAME}:${IMAGE_TAG}
                        docker push ${IMAGE_NAME}:latest
                        echo "✅ Images pushées avec succès"
                    """
                }
            }
        }

        stage('Déployer sur Cluster Kubernetes') {
            steps {
                echo "========================================="
                echo "STAGE 4 : Déploiement sur Kubernetes"
                echo "========================================="

                script {
                    sh '''
                        echo "⚙️  Vérification de kubectl..."
                        kubectl version --client
                    '''

                    sh """
                        echo "📦 Vérification du namespace ${K8S_NAMESPACE}..."
                        kubectl get namespace ${K8S_NAMESPACE} || kubectl create namespace ${K8S_NAMESPACE}
                    """

                    // Déployer PostgreSQL (seulement s'il n'existe pas déjà)
                    sh """
                        echo "🗄️  Déploiement de PostgreSQL..."
                        kubectl apply -f postgres-deployment.yaml

                        echo "⏳ Attente que PostgreSQL soit prêt..."
                        kubectl wait --for=condition=ready pod -l app=postgres -n ${K8S_NAMESPACE} --timeout=300s || {
                            echo "⚠️  PostgreSQL prend du temps, vérification..."
                            kubectl get pods -n ${K8S_NAMESPACE}
                        }
                    """

                    // Mettre à jour le deployment Spring Boot avec le nouveau tag
                    sh """
                        echo "🚀 Mise à jour de l'image Spring Boot vers version ${IMAGE_TAG}..."
                        kubectl set image deployment/spring-deployment springboot=${IMAGE_NAME}:${IMAGE_TAG} -n ${K8S_NAMESPACE} || {
                            echo "📝 Deployment n'existe pas encore, création..."
                            kubectl apply -f spring-deployment.yaml
                        }

                        echo "⏳ Attente du rollout..."
                        kubectl rollout status deployment/spring-deployment -n ${K8S_NAMESPACE} --timeout=300s
                    """

                    // Afficher l'état
                    sh """
                        echo ""
                        echo "========================================="
                        echo "📊 ÉTAT DU DÉPLOIEMENT"
                        echo "========================================="

                        echo ""
                        echo "🔹 Pods :"
                        kubectl get pods -n ${K8S_NAMESPACE} -o wide

                        echo ""
                        echo "🔹 Services :"
                        kubectl get svc -n ${K8S_NAMESPACE}

                        echo ""
                        echo "🔹 Deployments :"
                        kubectl get deployments -n ${K8S_NAMESPACE}
                    """

                    // Obtenir l'URL
                    sh """
                        echo ""
                        echo "========================================="
                        echo "🌐 ACCÈS À L'APPLICATION"
                        echo "========================================="

                        if command -v minikube &> /dev/null; then
                            echo "🔗 URL d'accès :"
                            minikube service spring-service -n ${K8S_NAMESPACE} --url || {
                                echo "💡 Commande : minikube service spring-service -n ${K8S_NAMESPACE} --url"
                                echo "💡 Ou : http://\$(minikube ip):30080"
                            }
                        else
                            NODE_IP=\$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[0].address}')
                            echo "💡 Accès via NodePort : http://\${NODE_IP}:30080"
                        fi
                    """
                }
            }
        }
    }

    post {
        success {
            echo ""
            echo "========================================="
            echo "✅ PIPELINE EXÉCUTÉ AVEC SUCCÈS !"
            echo "========================================="
            echo ""
            echo "🎉 Version ${IMAGE_TAG} déployée sur Kubernetes"
            echo ""
            echo "📌 Prochaines étapes :"
            echo "   1. Vérifier : kubectl get pods -n ${K8S_NAMESPACE}"
            echo "   2. Logs : kubectl logs -l app=springboot -n ${K8S_NAMESPACE}"
            echo "   3. Accès : minikube service spring-service -n ${K8S_NAMESPACE}"
            echo ""

            script {
                sh """
                    echo "📊 Résumé :"
                    kubectl get all -n ${K8S_NAMESPACE}
                """
            }
        }

        failure {
            echo ""
            echo "========================================="
            echo "❌ ÉCHEC DU PIPELINE"
            echo "========================================="

            script {
                sh """
                    echo "🔹 Pods :"
                    kubectl get pods -n ${K8S_NAMESPACE} || echo "Erreur récupération pods"

                    echo ""
                    echo "🔹 Événements :"
                    kubectl get events -n ${K8S_NAMESPACE} --sort-by='.lastTimestamp' | tail -20 || true

                    echo ""
                    echo "🔹 Logs Spring Boot :"
                    kubectl logs -l app=springboot -n ${K8S_NAMESPACE} --tail=50 || echo "Pas de logs"

                    echo ""
                    echo "🔹 Logs PostgreSQL :"
                    kubectl logs -l app=postgres -n ${K8S_NAMESPACE} --tail=50 || echo "Pas de logs"
                """
            }
        }

        always {
            echo ""
            echo "========================================="
            echo "🧹 NETTOYAGE"
            echo "========================================="

            script {
                sh '''
                    docker logout || true
                    docker image prune -f || true
                    echo "✅ Nettoyage terminé"
                '''
            }

            echo ""
            echo "📝 FIN DU PIPELINE"
        }
    }
}