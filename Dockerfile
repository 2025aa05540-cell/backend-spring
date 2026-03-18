FROM maven:3.9.6-eclipse-temurin-17
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:resolve
COPY src/ ./src/
RUN mvn clean package -DskipTests
EXPOSE 8081
CMD ["java", "-jar", "target/spring-boot-data-jpa-0.0.1-SNAPSHOT.jar"]