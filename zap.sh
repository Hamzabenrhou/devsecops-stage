PORT=$(kubectl -n default get svc ${serviceName} -o json | jq -r '.spec.ports[].nodePort')

mkdir -p $(pwd)/zap/wrk
sudo chown -R $(id -u):$(id -g) $(pwd)/zap/wrk

echo "$(id -u):$(id -g)"

docker run -v $(pwd)/zap/wrk/:/zap/wrk -v $(pwd)/zap/filter.py:/zap/filter.py -t zaproxy/zap-weekly \
  zap-api-scan.py -t "$applicationURL:$PORT/v3/api-docs" -f openapi \
  -r /zap/wrk/zap_report.html --hook=/zap/filter.py


exit_code=$?

sudo mkdir -p owasp-zap-report
sudo mv $(pwd)/zap/wrk/zap_report.html owasp-zap-report/
sudo chown $(id -u):$(id -g) owasp-zap-report/zap_report.html

echo "Exit Code : $exit_code"

if [[ $exit_code -ne 0 ]]; then
  echo "OWASP ZAP Report has either Low/Medium/High Risk. Please check the HTML Report"
  exit 1
else
  echo "OWASP ZAP did not report any Risk"
fi
