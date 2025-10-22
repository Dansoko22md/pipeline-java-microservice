# Spring Boot Microservice with DevOps Pipeline

This project is a Java Spring Boot microservice with complete DevOps pipeline implementation using Jenkins, Docker, and Kubernetes. The application manages client data with REST API endpoints and integrates with PostgreSQL database.

## 🚀 Technologies

- Java 17
- Spring Boot
- PostgreSQL
- Docker
- Kubernetes
- Jenkins Pipeline
- Maven

## 📋 Prerequisites

- Java JDK 17 or higher
- Docker
- Kubernetes cluster (or Minikube for local development)
- Jenkins
- Maven
- PostgreSQL

## 🏗️ Project Structure

```
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   └── tn/esprit/devops/
│   │   │       ├── controllers/
│   │   │       ├── entities/
│   │   │       ├── repositories/
│   │   │       └── services/
│   │   └── resources/
│   │       └── application.properties
├── k8s/
├── Dockerfile
├── Jenkinsfile
├── pom.xml
└── kubernetes deployment files
```

## 🔧 Configuration

### Application Properties

The application can be configured through `application.properties`:
- Database configuration
- Server port
- Logging settings

### Kubernetes Configuration

The application includes Kubernetes deployment files:
- `postgres-deployment.yaml`: PostgreSQL database deployment
- `spring-deployment.yaml`: Spring Boot application deployment

## 🐳 Docker

### Building the Docker Image

```bash
docker build -t your-registry/spring-microservice:latest .
```

### Running the Container

```bash
docker run -p 8080:8080 your-registry/spring-microservice:latest
```

## ☸️ Kubernetes Deployment

### Deploy PostgreSQL

```bash
kubectl apply -f postgres-deployment.yaml
```

### Deploy Spring Application

```bash
kubectl apply -f spring-deployment.yaml
```

## 🔄 CI/CD Pipeline

The project includes a Jenkins pipeline defined in `Jenkinsfile` with the following stages:
1. Checkout
2. Build
3. Test
4. Docker Build
5. Docker Push
6. Deploy to Kubernetes

## 📚 API Endpoints

The application exposes REST endpoints for client management:

- GET `/clients`: Retrieve all clients
- POST `/clients`: Create a new client
- PUT `/clients/{id}`: Update an existing client
- DELETE `/clients/{id}`: Delete a client
- GET `/clients/{id}`: Get a specific client

## 🧪 Testing

Run the tests using Maven:

```bash
mvn test
```

## 🚀 Local Development

### Run with Docker Compose

1. Start the services:
```bash
docker-compose up -d
```

2. Stop the services:
```bash
docker-compose down
```

### Run with Minikube

1. Start Minikube:
```bash
minikube start
```

2. Apply Kubernetes configurations:
```bash
./test-kubernetes-local.sh
```

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👥 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## ✨ Authors

* **Moussa Dansoko** - *Initial work*