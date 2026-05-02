 # -------- Step 1: Build Stage -------- 
FROM maven:3.8.3-openjdk-17 AS builder
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline
COPY src ./src
RUN mvn clean install -DskipTests=true

# -------- Step 2: Run Stage --------
FROM eclipse-temurin:17-jdk
WORKDIR /app
COPY --from=builder /app/target/*.jar /app/target/expenseapp.jar
RUN groupadd -r appgroup && useradd -r -g appgroup -m appuser
USER appuser
EXPOSE 8082
ENTRYPOINT ["java", "-jar", "/app/target/expenseapp.jar"]
