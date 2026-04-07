FROM python:3.8-slim-buster

EXPOSE 8080
ARG JAR_FILE=target/*.jar

# Adjusted user creation for Debian/Ubuntu environments
RUN groupadd -r devops-security && useradd -r -u 999 -g devops-security devsecops

COPY ${JAR_FILE} /home/devsecops/app.jar

# Set ownership so the non-root user can access the jar
RUN chown devsecops:devops-security /home/devsecops/app.jar

USER 999
ENTRYPOINT ["java","-jar","/home/devsecops/app.jar"]