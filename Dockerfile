# Usamos una imagen de Maven optimizada para empaquetar de forma ligera
FROM maven:3.8.5-openjdk-17-slim AS build
WORKDIR /app
COPY . .

# Optimizamos los parámetros de Maven para que no consuma más de la RAM permitida por Render
RUN mvn clean package -DskipTests -Dmaven.javadoc.skip=true -Dspring-boot.repackage.skip=false

# Cambiamos a la imagen de ejecución ultraligera
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar

# Le decimos a Java que use poca memoria RAM en ejecución para que no se caiga la instancia Free
ENV JAVA_OPTS="-XX:+UseSerialGC -Xss512k -XX:MaxRAM=400m"

EXPOSE 8080
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
