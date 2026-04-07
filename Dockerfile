# Changed from alpine-slim to a standard openjdk image (contains many CVEs for the demo)
FROM openjdk:8-jdk

EXPOSE 8080
ARG JAR_FILE=target/*.jar

# Adjusted user creation for Debian/Ubuntu (standard openjdk image)
RUN groupadd -r devops-security && useradd -r -u 999 -g devops-security devsecops

COPY ${JAR_FILE} /home/devsecops/app.jar

# Set ownership so the non-root user can access the jar
RUN chown devsecops:devops-security /home/devsecops/app.jar

USER 999
ENTRYPOINT ["java","-jar","/home/devsecops/app.jar"]
