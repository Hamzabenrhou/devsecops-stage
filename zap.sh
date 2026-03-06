#!/bin/bash -e

# Get the NodePort dynamically
PORT=$(kubectl -n default get svc ${serviceName} -o json | jq -r '.spec.ports[].nodePort')

if [ -z "$PORT" ] || [ "$PORT" = "null" ]; then
    echo "ERROR: Could not get NodePort"
    kubectl -n default get svc
    exit 0
fi

echo "Found NodePort: $PORT"

# Setup directories
mkdir -p owasp-zap-report
mkdir -p zap/wrk
chmod 777 zap/wrk 2>/dev/null || true
chmod 777 owasp-zap-report 2>/dev/null || true

# Construct the URL properly
# Ensure applicationURL starts with http:// (e.g., http://104.197.188.180)
FULL_URL="${applicationURL}:${PORT}"

echo "Testing connectivity to: ${FULL_URL}/check?name=test"
# Using -L to follow redirects if they exist
curl -IsL "${FULL_URL}/check?name=test" || echo "Warning: Could not reach endpoint via curl"

# Run ZAP Full Scan
# Targeting the specific endpoint forces ZAP to attack the 'name' parameter
echo "Running ZAP full scan on targeted endpoint..."
set +e
docker run --rm \
    -v "$(pwd)/zap/wrk:/zap/wrk" \
    --user root \
    zaproxy/zap-stable:latest \
    zap-full-scan.py \
    -t "${FULL_URL}/check?name=test" \
    -r zap_report.html \
    -J zap_report.json \
    -I
ZAP_EXIT_CODE=$?
set -e

echo "ZAP exit code: $ZAP_EXIT_CODE"

# Move and cleanup reports
if [ -f "zap/wrk/zap_report.html" ]; then
    cp zap/wrk/zap_report.html owasp-zap-report/
    cp zap/wrk/zap_report.json owasp-zap-report/
    echo "=== ZAP Scan Summary ==="
    # This will grep for the High risk alert in the HTML report
    grep -oP '(?<=<div>)High(?=</div>)' owasp-zap-report/zap_report.html || echo "No High Risk Found Yet"
else
    echo "Error: ZAP Report generation failed."
fi

exit 0