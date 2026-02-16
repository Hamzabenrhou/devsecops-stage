#!/bin/bash

# ... your existing code ...

if [ -f "zap/wrk/zap_report.html" ]; then
    echo "Report generated successfully"

    # Create a simplified version without problematic content
    cp zap/wrk/zap_report.html owasp-zap-report/zap_report_original.html 2>/dev/null || true

    # Create a wrapper HTML file
    cat > owasp-zap-report/zap_report.html << 'EOF'
<html>
<head>
    <title>OWASP ZAP Scan Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .header { background-color: #333; color: white; padding: 10px; }
        .content { padding: 20px; }
    </style>
</head>
<body>
    <div class="header">
        <h1>OWASP ZAP Security Scan Report</h1>
    </div>
    <div class="content">
        <p><strong>Scan completed at:</strong> $(date)</p>
        <p><strong>Target URL:</strong> ${FULL_URL}</p>
        <p><strong>Status:</strong> Completed</p>
        <p><strong>Note:</strong> The full report is available in the build artifacts.</p>
        <hr>
        <h2>Quick Summary</h2>
EOF

    # Extract summary from original report
    grep -E "High|Medium|Low|PASS|WARN" zap/wrk/zap_report.html >> owasp-zap-report/zap_report.html 2>/dev/null || true

    cat >> owasp-zap-report/zap_report.html << 'EOF'
        <hr>
        <p><em>For detailed results, check the console output.</em></p>
    </div>
</body>
</html>
EOF

    chmod 644 owasp-zap-report/zap_report.html 2>/dev/null || true
    echo "Simplified report saved"
else
    echo "Warning: Report not generated"
fi