
# Use a multi-stage build for smaller final image
FROM maven:3.8.6-openjdk-11-slim AS build

# Set the working directory
WORKDIR /app

# Copy the pom.xml file to download dependencies
COPY pom.xml .

# Download dependencies (this layer will be cached if pom.xml doesn't change)
RUN mvn dependency:go-offline -B

# Copy the source code
COPY src ./src

# Build the application
RUN mvn package -DskipTests

# Second stage: runtime
FROM openjdk:11-jre-slim

# Set the working directory
WORKDIR /app

# Add a non-root user
RUN adduser --system --group springuser
USER springuser

# Set environment variables
ENV SPRING_PROFILES_ACTIVE=production
ENV SERVER_PORT=8080

# Copy the built JAR from the build stage
COPY --from=build /app/target/*.jar app.jar

# Expose the port the app runs on
EXPOSE 8080

# Command to run the application
ENTRYPOINT ["java", "-jar", "app.jar"]

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1