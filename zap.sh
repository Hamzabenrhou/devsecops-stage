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
# ... (after getting PORT)
FULL_URL="http://104.197.188.180:${PORT}"

echo "Waiting for service to be reachable at ${FULL_URL}..."
# Loop for 60 seconds to wait for the Pod to be ready
for i in {1..12}; do
    if curl -sL --connect-timeout 5 "${FULL_URL}/check?name=test" > /dev/null; then
        echo "SUCCESS: App is reachable!"
        CONNECTED=true
        break
    fi
    echo "Attempt $i: App not reachable yet, waiting 5s..."
    sleep 5
done

if [ "$CONNECTED" != true ]; then
    echo "ERROR: App never became reachable at ${FULL_URL}. Checking K8s logs..."
    kubectl logs -l app=your-app-label --tail=20
    exit 0 # Exit so pipeline doesn't crash, but you'll know why it failed
fi

# Run ZAP
echo "Running ZAP full scan..."
set +e
docker run --rm \
    --network host \
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
    # This takes the multi-line ZAP report and turns it into a single line for Wazuh
    # Move and cleanup reports
    # Move and cleanup reports
    if [ -f "zap/wrk/zap_report.json" ]; then
        echo "=== Processing ZAP Report for Wazuh ==="

        # 1. Filter AND Minify in one command
        # This keeps only the Alert Name, Risk Code, URL, and Payload
        cat "zap/wrk/zap_report.json" | jq -c '{
          alerts: [.site[].alerts[] | {alert: .alert, risk: .riskcode, uri: .instances[0].uri, attack: .instances[0].attack}]
        }' > "zap/wrk/zap_report.min.json"

        # 2. Overwrite the original with the small version
        mv "zap/wrk/zap_report.min.json" "zap/wrk/zap_report.json"

        # 3. Fix permissions so Wazuh Agent can read it
        chmod 644 "zap/wrk/zap_report.json"

        # 4. Copy to your backup/artifact folder
        cp "zap/wrk/zap_report.json" owasp-zap-report/
        cp "zap/wrk/zap_report.html" owasp-zap-report/

        echo "=== SUCCESS: JSON reduced for Wazuh-n8n pipeline ==="
    else
        echo "Error: zap_report.json not found in zap/wrk/"
    fi
    # This will grep for the High risk alert in the HTML report
    grep -oP '(?<=<div>)High(?=</div>)' owasp-zap-report/zap_report.html || echo "No High Risk Found Yet"
else
    echo "Error: ZAP Report generation failed."
fi

exit 0