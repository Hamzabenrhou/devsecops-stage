**Security Advisory:** The `python:3.9-slim-buster` image contains a HIGH vulnerability CVE-2022-1304 in the package `e2fsprogs`. Consider using an alternative Docker image that is free from known vulnerabilities, such as `python:3.9-slim-bookworm`, to mitigate this risk.

**Corrected Dockerfile:**
FROM python:3.9-slim-bookworm

EXPOSE 8080
ARG JAR_FILE=target/*.jar

# Adjusted user creation for Debian/Ubuntu environments
RUN groupadd -r devops-security && useradd -r -u 999 -g devops-security devsecops

COPY ${JAR_FILE} /home/devsecops/app.jar

# Set ownership so the non-root user can access the jar
RUN chown devsecops:devops-security /home/devsecops/app.jar

USER 999
ENTRYPOINT ["java","-jar","/home/devsecops/app.jar"]

This change updates the base image to `python:3.9-slim-bookworm`, which is less likely to contain the mentioned vulnerability, enhancing the overall security posture of your containerized application.