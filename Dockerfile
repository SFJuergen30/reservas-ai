# Usamos Java 11 (Slim) para que Lombok compile sin romper la seguridad de Java
FROM maven:3.8.5-openjdk-11-slim AS build
WORKDIR /app
COPY . .

# Compilamos saltándonos los tests y documentación
RUN mvn clean package -DskipTests -Dmaven.javadoc.skip=true

# Cambiamos a la imagen de ejecución ligera basada en Java 11
FROM eclipse-temurin:11-jre-alpine
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar

# Control estricto de memoria para que Render Free no sufra
ENV JAVA_OPTS="-XX:+UseSerialGC -Xss512k -XX:MaxRAM=400m"

EXPOSE 8080
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
