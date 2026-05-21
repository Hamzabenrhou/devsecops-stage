FROM adoptopenjdk/openjdk8:jdk8u202-b08-alpine3.14

EXPOSE 8080

ARG JAR_FILE=target/*.jar

RUN addgroup -S devops-security && \
    adduser -u 999 -S devsecops -G devops-security && \
    apk update && \
    apk upgrade musl=1.1.20-r5

COPY ${JAR_FILE} /home/devsecops/app.jar
USER 999
ENTRYPOINT ["java","-jar","/home/devsecops/app.jar"]