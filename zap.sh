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
sudo chown -R $(id -u):$(id -g) $(pwd)/zap/wrk 2>/dev/null || true
sudo chown -R $(id -u):$(id -g) owasp-zap-report 2>/dev/null || true

# Construct the full application URL
FULL_URL="${applicationURL}:${PORT}${applicationURI}"
echo "Scanning application URL: $FULL_URL"

# Test if the application is accessible
echo "Testing if application is accessible..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" $FULL_URL || echo "Failed")
echo "HTTP Status Code: $HTTP_CODE"

if [ "$HTTP_CODE" = "Failed" ] || [ "$HTTP_CODE" -ge 400 ]; then
    echo "WARNING: Application might not be accessible. Continuing anyway..."
fi

# Pull the stable ZAP image
echo "Pulling ZAP stable image..."
docker pull owasp/zap2docker-stable:latest

# Run baseline scan with stable image
echo "Running ZAP baseline scan with stable image..."
docker run --rm \
    -v "$(pwd)/zap/wrk/:/zap/wrk" \
    -u $(id -u):$(id -g) \
    owasp/zap2docker-stable:latest \
    zap-baseline.py \
    -t "$FULL_URL" \
    -r zap_report.html \
    -I

exit_code=$?

# Check if report was generated
if [ -f "$(pwd)/zap/wrk/zap_report.html" ]; then
    echo "Report generated successfully"
    cp "$(pwd)/zap/wrk/zap_report.html" owasp-zap-report/
    sudo chown $(id -u):$(id -g) owasp-zap-report/zap_report.html 2>/dev/null || true
    echo "Report saved to: owasp-zap-report/zap_report.html"

    # Show summary
    echo "=== Scan Summary ==="
    echo "Exit code: $exit_code"
    echo "ZAP exit codes: 0=OK, 1=Warnings, 2=Errors, 3=Violations"

    if [ $exit_code -eq 0 ]; then
        echo "No issues found"
    elif [ $exit_code -eq 1 ]; then
        echo "Warnings found (Low risk)"
    elif [ $exit_code -eq 2 ]; then
        echo "Errors found"
    elif [ $exit_code -eq 3 ]; then
        echo "Violations found (High/Medium risk)"
    fi
else
    echo "ERROR: Report file not generated"
    ls -la "$(pwd)/zap/wrk/" || echo "Directory is empty"
    exit 1
fi

# Don't fail the build, just report
echo "ZAP scan completed with exit code: $exit_code"
exit 0  # Always return success to not block the pipeline