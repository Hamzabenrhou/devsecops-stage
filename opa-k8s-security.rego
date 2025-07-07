package main

# Ensure Service type is NodePort
deny contains msg if {
    input.kind == "Service"
    not input.spec.type == "NodePort"
    msg := "Service type should be NodePort"
}

# Ensure Deployment containers do not run as root
deny contains msg if {
    input.kind == "Deployment"
    not input.spec.template.spec.containers[0].securityContext.runAsNonRoot == true
    msg := "Containers must not run as root - use runAsNonRoot within container security context"
}