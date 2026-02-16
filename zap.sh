#!/bin/bash -e

# Get the NodePort dynamically
PORT=$(kubectl -n default get svc ${serviceName} -o json | jq -r '.spec.ports[].nodePort')

if [ -z "$PORT" ] || [ "$PORT" = "null" ]; then
    echo "ERROR: Could not get NodePort"
    kubectl -n default get svc
    exit 1
fi

echo "Found NodePort: $PORT"

# Create directories
mkdir -p owasp-zap-report
mkdir -p zap/wrk

# Full URL
FULL_URL="${applicationURL}:${PORT}${applicationURI}"
echo "Scanning: $FULL_URL"

# Run ZAP scan with the correct image
docker run --rm \
    -v "$(pwd)/zap/wrk:/zap/wrk" \
    zaproxy/zap-weekly:latest \
    zap-baseline.py \
    -t "$FULL_URL" \
    -r zap_report.html \
    -I || true

# Copy report if it exists
if [ -f "zap/wrk/zap_report.html" ]; then
    cp zap/wrk/zap_report.html owasp-zap-report/
    echo "Report saved to owasp-zap-report/zap_report.html"
else
    echo "Warning: Report not generated"
fi

# Always exit successfully to continue pipeline
exit 0