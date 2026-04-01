FROM adoptopenjdk/openjdk8:latest
EXPOSE 8080
ARG JAR_FILE=target/*.jar
RUN addgroup -r devops-security && adduser -u 999 -r devsecops -G devops-security
COPY ${JAR_FILE} /home/devsecops/app.jar
USER 999
ENTRYPOINT ["java","-jar","/home/devsecops/app.jar"]
