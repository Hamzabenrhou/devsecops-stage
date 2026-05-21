FROM adoptopenjdk/openjdk8:jdk8u202-b08-alpine
RUN apk update && apk upgrade libssl1.1 --available --allow-untrusted -o http://dl-cdn.alpinelinux.org/alpine/v3.14/main/ && \
    addgroup -S devops-security && adduser -u 999 -S devsecops -G devops-security
EXPOSE 8080
ARG JAR_FILE=target/*.jar
COPY ${JAR_FILE} /home/devsecops/app.jar
USER 999
ENTRYPOINT ["java","-jar","/home/devsecops/app.jar"]