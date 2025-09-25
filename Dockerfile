
FROM maven:3.8.6-eclipse-temurin-17 AS build

WORKDIR /app

COPY pom.xml .

RUN  mvn dependency:go-offline

COPY src ./src

RUN mvn clean package -DskipTests

FROM openjdk:17-jdk-slim

WORKDIR /app

COPY --from=build /app/target/monprojet-0.0.1-SNAPSHOT.jar .

EXPOSE 8080
# Expose the port the app runs on
ENTRYPOINT ["java", "-jar", "monprojet-0.0.1-SNAPSHOT.jar"]
# docker build -t backend:latest .
