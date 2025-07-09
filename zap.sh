#!/bin/bash

# Ensure serviceName is defined
if [ -z "${serviceName}" ]; then
  echo "Error: serviceName is not defined. Please set the serviceName environment variable."
  exit 1
fi

# Get the nodePort from the Kubernetes service
PORT=$(kubectl -n default get svc "${serviceName}" -o json | jq .spec.ports[].nodePort 2>/dev/null)
if [ -z "$PORT" ]; then
  echo "Error: Could not retrieve nodePort for service ${serviceName}. Check if the service exists."
  exit 1
fi

# Ensure applicationURL is defined and starts with http:// or https://
if [ -z "${applicationURL}" ]; then
  echo "Error: applicationURL is not defined. Please set the applicationURL environment variable."
  exit 1
fi
if [[ ! "${applicationURL}" =~ ^https?:// ]]; then
  echo "Error: applicationURL must start with http:// or https://"
  exit 1
fi

# Debug: Print the target URL
echo "Target URL: ${applicationURL}:${PORT}/v3/api-docs"

# Create and set permissions for the working directory
WORK_DIR=$(pwd)/zap/wrk
mkdir -p "${WORK_DIR}"
sudo chown $(id -u):$(id -g) "${WORK_DIR}"
sudo chmod 755 "${WORK_DIR}"

# Debug: Print user and group IDs
echo "$(id -u):$(id -g)"

# Run ZAP scan
docker run -v "${WORK_DIR}:/zap/wrk" -t zaproxy/zap-weekly zap-api-scan.py -t "${applicationURL}:${PORT}/v3/api-docs" -f openapi -r zap_report.html

exit_code=$?

# Create report directory and move the report
sudo mkdir -p owasp-zap-report
if [ -f "${WORK_DIR}/zap_report.html" ]; then
  sudo mv "${WORK_DIR}/zap_report.html" owasp-zap-report/
  sudo chown $(id -u):$(id -g) owasp-zap-report
else
  echo "Warning: zap_report.html was not generated."
fi

# Print exit code
echo "Exit Code : $exit_code"

# Check exit code and report
if [[ $exit_code -ne 0 ]]; then
  echo "OWASP ZAP Report has either Low/Medium/High Risk. Please check the HTML Report"
  exit 1
else
  echo "OWASP ZAP did not report any Risk"
fi