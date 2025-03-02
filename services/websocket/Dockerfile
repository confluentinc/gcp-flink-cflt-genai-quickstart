# Define the base image for building the React app
FROM node:23-alpine3.20 AS node_builder

# Set working directory for React app
WORKDIR /app

# Copy package.json and package-lock.json (or yarn.lock) for React app
COPY frontend/package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the React app files
COPY frontend/. .

# Build the React app
RUN npm run build

# ----- Spring Boot Build Stage -----
FROM maven:3-eclipse-temurin-21-alpine AS builder

WORKDIR /build

# Copy the pom.xml file
COPY pom.xml .

# Go offline with all dependencies
RUN mvn dependency:go-offline

# Copy the built React app into the Spring Boot application resources
COPY --from=node_builder /app/dist /build/src/main/resources/static

# Copy the source code of Spring Boot application
COPY src/ /build/src/

# Package the Spring Boot application
RUN mvn package

# ----- Application Image -----
FROM eclipse-temurin:21-jre-alpine

# Create an app directory to hold the Spring Boot Application
WORKDIR /app

# Copy the built Spring Boot application jar
COPY --from=builder /build/target/*.jar /app/app.jar

# Expose the port Spring Boot runs on
EXPOSE 8080

# Run the Spring Boot application
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
