#!/bin/bash

# 1. Identify the image from the Dockerfile
imageName=$(awk '/FROM/ {print $2}' Dockerfile)
echo "--- Starting Trivy Scan for: $imageName ---"

# 2. Run a single scan for both HIGH and CRITICAL
# We use --format json so Wazuh can parse the fields (CVE ID, Package, etc.)
trivy image --severity HIGH,CRITICAL --format json --output /tmp/trivy_result.json "$imageName"

# 3. Flatten the JSON for Wazuh ingestion
# This turns the big report into one-line-per-vulnerability JSONs
if [ -f /tmp/trivy_result.json ]; then
    jq -c '.Results[]?.Vulnerabilities[]? | {integration: "trivy", image: "'"$imageName"'", vuln_id: .VulnerabilityID, pkg: .PkgName, severity: .Severity, installed: .InstalledVersion, fixed: .FixedVersion}' /tmp/trivy_result.json >> /var/log/trivy_scan.log
fi

echo "--- Scan complete. Results sent to /var/log/trivy_scan.log ---"