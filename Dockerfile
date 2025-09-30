# Étape 1 : Build avec Maven
FROM maven:3.8.6-eclipse-temurin-17 AS build

WORKDIR /app

# Copier uniquement pom.xml d'abord (cache pour les dépendances)
COPY pom.xml .

RUN mvn dependency:go-offline

# Copier ensuite le code source
COPY src ./src

# Compiler le projet sans les tests
RUN mvn clean package -DskipTests

# Étape 2 : Image finale (plus légère)
FROM eclipse-temurin:17-jre-slim

WORKDIR /app

# Copier le jar depuis l'étape de build
# Le * permet d'éviter de hardcoder le nom exact du jar
COPY --from=build /app/target/*.jar app.jar

# Exposer le port
EXPOSE 8080

# Commande de démarrage
ENTRYPOINT ["java", "-jar", "app.jar"]
