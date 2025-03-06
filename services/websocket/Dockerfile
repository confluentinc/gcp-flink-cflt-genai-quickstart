# Stage 1: Build the front-end
FROM node:23-alpine3.20 AS frontend-build
WORKDIR /app
# Assuming your frontend is located in src/main/frontend
COPY frontend/ ./
# Install dependencies and build the frontend
RUN npm install

RUN npm run build
# The build command should output the static files to the /app/build directory (this might vary depending on your frontend framework)

# Stage 2: Build the Spring Boot application
FROM maven:3.9.4-eclipse-temurin-21-alpine AS backend-build

WORKDIR /backend
# Copy the pom.xml file and source code
COPY pom.xml .

COPY src ./src
# Copy built frontend assets from the previous stage into the Spring Boot static resources directory
COPY --from=frontend-build /app/ /backend/src/main/resources/static/
# Build the application

RUN mvn clean package -DskipTests

# Stage 3: Create the final image
FROM openjdk:21-jdk-slim

WORKDIR /app
# Copy the Spring Boot application jar from the backend-build stage
COPY --from=backend-build /backend/target/*.jar /app/app.jar

EXPOSE 8080

ENTRYPOINT ["java","-jar","app.jar"]
