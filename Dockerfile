FROM python:3.9-slim-buster
EXPOSE 8080
ARG JAR_FILE=target/*.jar
RUN groupadd -r devops-security && useradd -r -u 999 -g devops-security devsecops
COPY ${JAR_FILE} /home/devsecops/app.jar
USER 999
ENTRYPOINT ["java","-jar","/home/devsecops/app.jar"]

