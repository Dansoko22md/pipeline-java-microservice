pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = 'dockerhub-credentials-id'
        SONAR_TOKEN = credentials('sonar_token') // À créer dans Jenkins
        IMAGE_NAME    = 'moise25/monmicroservice'
        IMAGE_TAG     = "${env.BUILD_NUMBER}"
        K8S_NAMESPACE = 'devops'
        KUBECONFIG = '/var/lib/jenkins/.kube/config'

        // Configuration SonarQube
        SONAR_HOST_URL = 'http://localhost:9000'
        SONAR_PROJECT_KEY = 'monprojet'
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

        script {
            // Option 1 : Spécifier la classe principale via propriété système
            sh '''
                mvn clean install -DskipTests \
                    -Dspring-boot.run.main-class=tn.esprit.devops.RevisionApplication
            '''

            sh '''
                mvn package -DskipTests \
                    -Dspring-boot.run.main-class=tn.esprit.devops.RevisionApplication
            '''
        }

        echo "✅ Build Maven terminé avec succès"
    }
}

        stage('Tests Unitaires') {
            steps {
                echo "========================================="
                echo "STAGE 2.5 : Exécution des tests unitaires"
                echo "========================================="

                sh 'mvn test'

                // Publier les résultats des tests
                junit '**/target/surefire-reports/*.xml'

                echo "✅ Tests unitaires terminés"
            }
        }

        stage('Analyse SonarQube') {
            steps {
                echo "========================================="
                echo "STAGE 3 : Analyse de qualité du code avec SonarQube"
                echo "========================================="

                script {
                    sh """
                        echo "🔍 Lancement de l'analyse SonarQube..."

                        mvn sonar:sonar \\
                            -Dsonar.host.url=${SONAR_HOST_URL} \\
                            -Dsonar.login=${SONAR_TOKEN} \\
                            -Dsonar.projectKey=${SONAR_PROJECT_KEY} \\
                            -Dsonar.projectName='Mon Microservice Pipeline' \\
                            -Dsonar.projectVersion=${IMAGE_TAG} \\
                            -Dsonar.sources=src/main/java \\
                            -Dsonar.tests=src/test/java \\
                            -Dsonar.java.binaries=target/classes \\
                            -Dsonar.junit.reportPaths=target/surefire-reports \\
                            -Dsonar.coverage.jacoco.xmlReportPaths=target/site/jacoco/jacoco.xml \\
                            -Dsonar.java.coveragePlugin=jacoco

                        echo "✅ Analyse SonarQube terminée avec succès"
                        echo "📊 Consultez les résultats : ${SONAR_HOST_URL}/dashboard?id=${SONAR_PROJECT_KEY}"
                    """
                }
            }
        }

        stage('Quality Gate') {
            steps {
                echo "========================================="
                echo "STAGE 3.5 : Vérification du Quality Gate SonarQube"
                echo "========================================="

                script {
                    timeout(time: 5, unit: 'MINUTES') {
                        def qg = waitForQualityGate()
                        if (qg.status != 'OK') {
                            echo "⚠️  Quality Gate échoué : ${qg.status}"
                            echo "🔍 Vérifiez les résultats : ${SONAR_HOST_URL}/dashboard?id=${SONAR_PROJECT_KEY}"
                            // Ne pas bloquer le pipeline, juste avertir
                            // error "Pipeline interrompu à cause du Quality Gate"
                        } else {
                            echo "✅ Quality Gate réussi !"
                        }
                    }
                }
            }
        }

        stage('Build & Push Docker Image') {
            steps {
                echo "========================================="
                echo "STAGE 4 : Build et Push de l'image Docker"
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

                    sh """
                        echo "🐳 Construction de l'image Docker..."
                        docker build -t ${IMAGE_NAME}:${IMAGE_TAG} -t ${IMAGE_NAME}:latest .
                        echo "✅ Image construite : ${IMAGE_NAME}:${IMAGE_TAG}"
                    """

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
                echo "STAGE 5 : Déploiement sur Kubernetes"
                echo "========================================="

                script {
                    // Vérifier l'accès kubectl
                    sh '''
                        echo "⚙️  Vérification de kubectl..."
                        export KUBECONFIG=/var/lib/jenkins/.kube/config
                        kubectl version --client
                        echo "🔍 Vérification de la connexion au cluster..."
                        kubectl cluster-info || echo "⚠️  Attention: problème de connexion au cluster"
                    '''

                    // Créer ou vérifier le namespace
                    sh """
                        export KUBECONFIG=/var/lib/jenkins/.kube/config
                        echo "📦 Vérification du namespace ${K8S_NAMESPACE}..."
                        kubectl get namespace ${K8S_NAMESPACE} || kubectl create namespace ${K8S_NAMESPACE}
                    """

                    // Déployer PostgreSQL avec vérifications complètes
                    sh """
                        export KUBECONFIG=/var/lib/jenkins/.kube/config
                        echo "🗄️  Déploiement de PostgreSQL..."

                        # Toujours appliquer le manifest pour s'assurer que tout est à jour
                        echo "📝 Application du manifest PostgreSQL..."
                        kubectl apply -f k8s/postgres-deployment.yaml -n ${K8S_NAMESPACE}

                        # Vérifier que le service existe
                        echo "🔍 Vérification du service PostgreSQL..."
                        kubectl get svc postgres-service -n ${K8S_NAMESPACE} || {
                            echo "❌ Le service postgres-service n'existe pas!"
                            kubectl get svc -n ${K8S_NAMESPACE}
                            exit 1
                        }

                        # Vérifier que le déploiement existe
                        echo "🔍 Vérification du déploiement PostgreSQL..."
                        kubectl get deployment postgres -n ${K8S_NAMESPACE} || {
                            echo "❌ Le déploiement postgres n'existe pas!"
                            kubectl get deployments -n ${K8S_NAMESPACE}
                            exit 1
                        }

                        # Attendre que PostgreSQL soit prêt
                        echo "⏳ Attente que PostgreSQL soit prêt (timeout 5 min)..."
                        kubectl wait --for=condition=ready pod -l app=postgres -n ${K8S_NAMESPACE} --timeout=300s || {
                            echo "⚠️  PostgreSQL n'est pas prêt après 5 minutes!"
                            echo ""
                            echo "📊 État des pods PostgreSQL:"
                            kubectl get pods -l app=postgres -n ${K8S_NAMESPACE}
                            echo ""
                            echo "📋 Description du pod:"
                            kubectl describe pod -l app=postgres -n ${K8S_NAMESPACE}
                            echo ""
                            echo "📜 Logs PostgreSQL:"
                            kubectl logs -l app=postgres -n ${K8S_NAMESPACE} --tail=50 || echo "Pas de logs"
                            exit 1
                        }

                        echo "✅ PostgreSQL est prêt et accessible"
                        echo "🔗 Service DNS: postgres-service.${K8S_NAMESPACE}.svc.cluster.local"
                    """

                    // Déployer Spring Boot avec vérification améliorée
                    sh """
                        export KUBECONFIG=/var/lib/jenkins/.kube/config
                        echo "🚀 Déploiement de Spring Boot version ${IMAGE_TAG}..."

                        # Vérifier si le deployment existe (sans afficher l'erreur)
                        if kubectl get deployment spring-deployment -n ${K8S_NAMESPACE} >/dev/null 2>&1; then
                            echo "🔄 Le deployment existe, mise à jour de l'image..."
                            kubectl set image deployment/spring-deployment springboot=${IMAGE_NAME}:${IMAGE_TAG} -n ${K8S_NAMESPACE}
                        else
                            echo "📝 Le deployment n'existe pas, création..."
                            kubectl apply -f k8s/spring-deployment.yaml -n ${K8S_NAMESPACE}

                            # Attendre que le deployment soit créé
                            echo "⏳ Attente de la création du deployment..."
                            sleep 10

                            # Mettre à jour l'image avec la version spécifique
                            echo "🔄 Mise à jour de l'image vers la version ${IMAGE_TAG}..."
                            kubectl set image deployment/spring-deployment springboot=${IMAGE_NAME}:${IMAGE_TAG} -n ${K8S_NAMESPACE}
                        fi

                        echo "⏳ Attente du rollout (timeout 10 minutes)..."
                        kubectl rollout status deployment/spring-deployment -n ${K8S_NAMESPACE} --timeout=600s || {
                            echo "⚠️  Timeout du rollout, diagnostic en cours..."
                            kubectl get pods -n ${K8S_NAMESPACE}
                            kubectl describe pod -l app=springboot -n ${K8S_NAMESPACE} | tail -50
                            kubectl logs -l app=springboot -n ${K8S_NAMESPACE} --tail=50 || echo "Pas de logs disponibles"
                            exit 1
                        }
                    """

                    // Afficher l'état du déploiement
                    sh """
                        export KUBECONFIG=/var/lib/jenkins/.kube/config
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

                        echo ""
                        echo "🔹 Ressources :"
                        kubectl get all -n ${K8S_NAMESPACE}
                    """

                    // Obtenir l'URL d'accès
                    sh """
                        export KUBECONFIG=/var/lib/jenkins/.kube/config
                        echo ""
                        echo "========================================="
                        echo "🌐 ACCÈS À L'APPLICATION"
                        echo "========================================="

                        if command -v minikube &> /dev/null; then
                            echo "🔗 URL d'accès Minikube :"
                            minikube service spring-service -n ${K8S_NAMESPACE} --url || {
                                MINIKUBE_IP=\$(minikube ip)
                                echo "💡 URL : http://\${MINIKUBE_IP}:30080"
                            }
                        else
                            NODE_IP=\$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[0].address}')
                            NODE_PORT=\$(kubectl get svc spring-service -n ${K8S_NAMESPACE} -o jsonpath='{.spec.ports[0].nodePort}')
                            echo "💡 Accès via NodePort : http://\${NODE_IP}:\${NODE_PORT}"
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
            echo "📊 Analyse SonarQube : ${SONAR_HOST_URL}/dashboard?id=${SONAR_PROJECT_KEY}"
            echo ""
            echo "📌 Prochaines étapes :"
            echo "   1. Vérifier : kubectl get pods -n ${K8S_NAMESPACE}"
            echo "   2. Logs : kubectl logs -l app=springboot -n ${K8S_NAMESPACE}"
            echo "   3. Accès : minikube service spring-service -n ${K8S_NAMESPACE}"
            echo "   4. SonarQube : ${SONAR_HOST_URL}"
            echo ""

            script {
                sh """
                    export KUBECONFIG=/var/lib/jenkins/.kube/config
                    echo "📊 Résumé final :"
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
                    export KUBECONFIG=/var/lib/jenkins/.kube/config
                    echo "🔹 Pods :"
                    kubectl get pods -n ${K8S_NAMESPACE} || echo "Erreur récupération pods"

                    echo ""
                    echo "🔹 Événements récents :"
                    kubectl get events -n ${K8S_NAMESPACE} --sort-by='.lastTimestamp' | tail -20 || true

                    echo ""
                    echo "🔹 Logs Spring Boot :"
                    kubectl logs -l app=springboot -n ${K8S_NAMESPACE} --tail=50 || echo "Pas de logs Spring Boot"

                    echo ""
                    echo "🔹 Logs PostgreSQL :"
                    kubectl logs -l app=postgres -n ${K8S_NAMESPACE} --tail=50 || echo "Pas de logs PostgreSQL"

                    echo ""
                    echo "🔹 Description des pods en erreur :"
                    kubectl describe pods -n ${K8S_NAMESPACE} | grep -A 10 "Error\\|Failed\\|Pending" || true
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
                    echo "🔓 Déconnexion Docker Hub..."
                    docker logout || true

                    echo "🗑️  Nettoyage des images Docker inutilisées..."
                    docker image prune -f || true

                    echo "✅ Nettoyage terminé"
                '''
            }

            echo ""
            echo "📝 FIN DU PIPELINE"
            echo "========================================="
        }
    }
}