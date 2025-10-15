#!/bin/bash

# Script de test Kubernetes pour WSL
set -e

echo "🎯 Test de Kubernetes sur WSL"
echo "========================================"

# 1. Vérifier Docker
echo ""
echo "🐳 Vérification de Docker..."
if ! docker ps &> /dev/null; then
    echo "❌ Docker n'est pas démarré!"
    echo "💡 Démarrez Docker Desktop depuis Windows"
    echo "💡 Et activez 'WSL 2 Integration' dans les paramètres"
    exit 1
fi
echo "✅ Docker fonctionne"

# 2. Démarrer Minikube
echo ""
echo "🚀 Démarrage de Minikube..."
minikube start --driver=docker --cpus=2 --memory=4096

# 3. Vérifier le cluster
echo ""
echo "✅ Vérification du cluster..."
minikube status
echo ""
kubectl get nodes

# 4. Créer le namespace devops
echo ""
echo "📦 Création du namespace 'devops'..."
kubectl create namespace devops 2>/dev/null || echo "Namespace 'devops' existe déjà"

# 5. Déployer une application de test
echo ""
echo "🐳 Déploiement de nginx pour test..."
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-test
  namespace: devops
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:alpine
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
  namespace: devops
spec:
  type: NodePort
  selector:
    app: nginx
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30080
EOF

# 6. Attendre que le pod soit prêt
echo ""
echo "⏳ Attente du démarrage..."
kubectl wait --for=condition=ready pod -l app=nginx -n devops --timeout=120s

# 7. Afficher l'état
echo ""
echo "📊 État du déploiement:"
echo "------------------------------------"
kubectl get all -n devops

# 8. Générer le kubeconfig pour Jenkins
echo ""
echo "📄 Génération du kubeconfig pour Jenkins..."
KUBECONFIG_FILE="jenkins-kubeconfig.yaml"
cp ~/.kube/config ${KUBECONFIG_FILE}

# Pour WSL, on garde l'adresse comme elle est (127.0.0.1)
# car Jenkins tournera aussi sur la même machine
echo "✅ Kubeconfig généré: ${KUBECONFIG_FILE}"

# 9. Tester l'accès
echo ""
echo "🧪 Test de l'application..."
echo "Attendez quelques secondes..."
sleep 5

# Sur WSL, on peut utiliser localhost directement
if curl -s http://localhost:30080 &> /dev/null; then
    echo "✅ Application accessible sur http://localhost:30080"
else
    echo "⚠️  Application pas encore prête. Essayez dans quelques secondes:"
    echo "   curl http://localhost:30080"
fi

# 10. Résumé
echo ""
echo "========================================="
echo "✅ CLUSTER KUBERNETES PRÊT!"
echo "========================================="
echo ""
echo "📌 Informations:"
echo "   • Namespace: devops"
echo "   • URL test: http://localhost:30080"
echo "   • Kubeconfig: ${KUBECONFIG_FILE}"
echo ""
echo "📚 Commandes utiles:"
echo "   kubectl get all -n devops"
echo "   kubectl logs -l app=nginx -n devops"
echo "   minikube dashboard"
echo "   minikube service nginx-service -n devops"
echo ""
echo "🎯 Pour Jenkins:"
echo "   1. Uploadez '${KUBECONFIG_FILE}' dans Jenkins"
echo "   2. ID du credential: 'kubeconfig-credentials'"
echo "   3. Lancez votre pipeline!"
echo ""
echo "⏹️  Pour arrêter: minikube stop"
echo "🗑️  Pour supprimer: minikube delete"
echo ""