package main

# Ensure Service type is NodePort
deny[msg] {
    input.kind == "Service"
    input.spec.type != "NodePort"
    msg := "Service type should be NodePort"
}

# Ensure Deployment containers do not run as root
deny[msg] {
    input.kind == "Deployment"
    container := input.spec.template.spec.containers[_]
    container.securityContext.runAsNonRoot != true
    msg := "Containers must not run as root - use runAsNonRoot within container security context"
}