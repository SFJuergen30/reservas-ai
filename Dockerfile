# Usamos Java 17 Slim para compilar
FROM maven:3.8.5-openjdk-17-slim AS build
WORKDIR /app
COPY . .

# El truco maestro: Le damos permisos a Lombok para acceder a las herramientas de compilación de Java 17
ENV MAVEN_OPTS="--add-opens java.base/java.lang=ALL-UNNAMED --add-opens jdk.compiler/com.sun.tools.javac.processing=ALL-UNNAMED --add-opens jdk.compiler/com.sun.tools.javac.validate=ALL-UNNAMED --add-opens jdk.compiler/com.sun.tools.javac.util=ALL-UNNAMED --add-opens jdk.compiler/com.sun.tools.javac.api=ALL-UNNAMED --add-opens jdk.compiler/com.sun.tools.javac.code=ALL-UNNAMED --add-opens jdk.compiler/com.sun.tools.javac.tree=ALL-UNNAMED"

# Compilamos de forma ligera saltándonos los tests
RUN mvn clean package -DskipTests -Dmaven.javadoc.skip=true

# Imagen de ejecución ultraligera para producción
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar

# Control estricto de memoria para que la instancia Free de Render vuele
ENV JAVA_OPTS="-XX:+UseSerialGC -Xss512k -XX:MaxRAM=400m"

EXPOSE 8080
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
