FROM alpine:3.15.0

# Install openssl with a known vulnerability
RUN apk add --no-cache openssl=1.1.1o-r0

# Install bash for better shell experience (optional, but good for debugging)
RUN apk add --no-cache bash

# Adjusted user creation for Alpine environments
RUN addgroup -S devops-security && adduser -S -u 999 -G devops-security devsecops

ARG JAR_FILE=target/*.jar
COPY ${JAR_FILE} /home/devsecops/app.jar

# Set ownership so the non-root user can access the jar
RUN chown devsecops:devops-security /home/devsecops/app.jar

USER 999
ENTRYPOINT ["java","-jar","/home/devsecops/app.jar"]