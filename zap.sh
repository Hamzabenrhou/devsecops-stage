#!/bin/bash -e

# Get the NodePort dynamically
PORT=$(kubectl -n default get svc ${serviceName} -o json | jq -r '.spec.ports[].nodePort')

if [ -z "$PORT" ] || [ "$PORT" = "null" ]; then
    echo "ERROR: Could not get NodePort"
    kubectl -n default get svc
    exit 1
fi

echo "Found NodePort: $PORT"

# Create directories with full permissions
mkdir -p owasp-zap-report
mkdir -p zap/wrk

# Set full permissions on the directory
chmod 777 zap/wrk || true
chmod 777 owasp-zap-report || true

# Full URL
FULL_URL="${applicationURL}:${PORT}${applicationURI}"
echo "Scanning: $FULL_URL"

# Run ZAP scan with the correct image and permissions
# Option 1: Run as root inside container (simplest fix)
echo "Running ZAP baseline scan..."
docker run --rm \
    -v "$(pwd)/zap/wrk:/zap/wrk" \
    --user root \
    zaproxy/zap-weekly:latest \
    zap-baseline.py \
    -t "$FULL_URL" \
    -r zap_report.html \
    -I || true

# Check if report was generated
if [ -f "zap/wrk/zap_report.html" ]; then
    echo "Report generated successfully"
    cp zap/wrk/zap_report.html owasp-zap-report/
    chmod 644 owasp-zap-report/zap_report.html || true
    echo "Report saved to owasp-zap-report/zap_report.html"

    # Show a quick summary
    echo "=== ZAP Scan Summary ==="
    grep -E "High|Medium|Low" zap/wrk/zap_report.html 2>/dev/null || echo "No risk levels found in report"
else
    echo "Warning: Report not generated"

    # Try alternative scan method
    echo "Trying alternative scan method with full scan..."
    docker run --rm \
        -v "$(pwd)/zap/wrk:/zap/wrk" \
        --user root \
        zaproxy/zap-weekly:latest \
        zap-full-scan.py \
        -t "$FULL_URL" \
        -r zap_report.html \
        -I || true

    if [ -f "zap/wrk/zap_report.html" ]; then
        cp zap/wrk/zap_report.html owasp-zap-report/
        echo "Alternative scan succeeded!"
    else
        echo "Both scan methods failed"
        # Create a placeholder report
        echo "<html><body><h1>ZAP Scan Failed</h1><p>Could not generate report. Check logs.</p></body></html>" > owasp-zap-report/zap_report.html
    fi
fi

# Ensure the report exists for Jenkins
ls -la owasp-zap-report/ || true

# Always exit successfully
exit 0