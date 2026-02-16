#!/bin/bash -e

# Debug: Print all environment variables
echo "Debug: serviceName = ${serviceName}"
echo "Debug: applicationURL = ${applicationURL}"
echo "Debug: applicationURI = ${applicationURI}"

# Get the NodePort dynamically
echo "Fetching NodePort for service: ${serviceName}"
PORT=$(kubectl -n default get svc ${serviceName} -o json | jq -r '.spec.ports[].nodePort')

if [ -z "$PORT" ] || [ "$PORT" = "null" ]; then
    echo "ERROR: Could not get NodePort for service ${serviceName}"
    kubectl -n default get svc
    exit 1
fi

echo "Found NodePort: $PORT"

# Create necessary directories
mkdir -p $(pwd)/zap/wrk
mkdir -p owasp-zap-report
sudo chown -R $(id -u):$(id -g) $(pwd)/zap/wrk
sudo chown -R $(id -u):$(id -g) owasp-zap-report

# Construct the full application URL
FULL_URL="${applicationURL}:${PORT}${applicationURI}"
echo "Scanning application URL: $FULL_URL"

# Run baseline scan instead of API scan
docker run --rm \
    -v $(pwd)/zap/wrk/:/zap/wrk \
    -u $(id -u):$(id -g) \
    zaproxy/zap-weekly \
    zap-baseline.py \
    -t "$FULL_URL" \
    -r zap_report.html

exit_code=$?

# Copy report
if [ -f "$(pwd)/zap/wrk/zap_report.html" ]; then
    cp $(pwd)/zap/wrk/zap_report.html owasp-zap-report/
    sudo chown $(id -u):$(id -g) owasp-zap-report/zap_report.html
    echo "Report saved to: owasp-zap-report/zap_report.html"
fi

echo "Exit Code : $exit_code"

if [[ $exit_code -ne 0 ]]; then
    echo "OWASP ZAP Report has either Low/Medium/High Risk. Please check the HTML Report"
    # exit 1  # Uncomment to fail the build
else
    echo "OWASP ZAP did not report any Risk"
fi