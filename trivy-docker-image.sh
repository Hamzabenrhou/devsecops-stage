#!/bin/bash

dockerImageName=$(awk 'NR==1 {print $2}' Dockerfile)
echo "Scanning image: $dockerImageName"

# Use local Trivy — no Docker daemon needed
trivy image --exit-code 0 --severity HIGH --light --cache-dir /tmp/.cache $dockerImageName
trivy image --exit-code 0 --severity CRITICAL --light --cache-dir /tmp/.cache $dockerImageName