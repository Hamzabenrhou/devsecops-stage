#!/bin/bash

# 1. Identify the image
imageName=$(awk '/FROM/ {print $2}' Dockerfile)
echo "--- Starting Trivy Scan for: $imageName ---"

# 2. Run scan and save to temp file
# We use --scanners vuln to avoid the secret scanning delay
trivy image --severity HIGH,CRITICAL --format json --scanners vuln --output /tmp/trivy_result.json "$imageName"

# 3. Check if file exists and has content
if [ ! -s /tmp/trivy_result.json ]; then
    echo "ERROR: /tmp/trivy_result.json is empty or was not created."
    exit 1
fi

# 4. Extract vulnerabilities using a more flexible JQ path
# This looks into all Results and all Vulnerabilities arrays
jq -c '.Results[]?.Vulnerabilities[]? | select(. != null) | {integration: "trivy", image: "'"$imageName"'", vuln_id: .VulnerabilityID, pkg: .PkgName, severity: .Severity, installed: .InstalledVersion, fixed: .FixedVersion}' /tmp/trivy_result.json >> /var/log/trivy_scan.log

# 5. Check if we actually wrote anything
if [ -s /var/log/trivy_scan.log ]; then
    echo "SUCCESS: Data written to /var/log/trivy_scan.log"
    tail -n 1 /var/log/trivy_scan.log
else
    echo "WARNING: Scan finished but no HIGH/CRITICAL vulnerabilities were found in the JSON."
    # Log a 'CLEAN' status so Wazuh knows the scan actually happened
    echo "{\"integration\": \"trivy\", \"image\": \"$imageName\", \"status\": \"CLEAN\"}" >> /var/log/trivy_scan.log
fi