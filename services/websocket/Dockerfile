# Step 1: Build stage using a Java 21 JDK base image; adjust the tag/version as necessary
FROM maven:3-eclipse-temurin-21-alpine AS build

# Set the working directory in the Docker image
WORKDIR /app

# Copy the Maven pom.xml and source code
COPY pom.xml .
RUN mvn dependency:go-offline

COPY src src

# If your project has any other directories or files needed during the build, copy them as well

# Run Maven build, skip tests to speed up the build process
RUN mvn package -DskipTests

# Step 2: Create the runtime stage with a JRE base image to keep the image lean
FROM eclipse-temurin:21-jre-alpine

# Set the working directory in the Docker image
WORKDIR /app

# Copy only the built artifact from the build stage to the new stage
COPY --from=build /app/target/*.jar app.jar

# Expose the port the application runs on
EXPOSE 8080

# Run the application
CMD ["java", "-jar", "app.jar"]
