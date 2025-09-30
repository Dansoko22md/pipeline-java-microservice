# Étape 1 : Build du projet avec Maven
FROM maven:3.8.6-eclipse-temurin-17 AS build

WORKDIR /app

# Copier uniquement le pom.xml pour utiliser le cache Maven
COPY pom.xml .

RUN mvn dependency:go-offline

# Copier ensuite le reste du projet
COPY src ./src

# Compiler et packager (sans tests)
RUN mvn clean package -DskipTests

# Étape 2 : Image finale légère pour exécuter le jar
FROM eclipse-temurin:17-jre-slim

WORKDIR /app

# Copier le jar depuis l'étape build
COPY --from=build /app/target/*.jar app.jar

# Exposer le port de l’application
EXPOSE 8080

# Lancer l’application
ENTRYPOINT ["java", "-jar", "app.jar"]
