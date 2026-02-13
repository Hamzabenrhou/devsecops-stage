package main

# List of suspicious environment variable names (lowercase)
secrets_env := ["passwd", "password", "pass", "secret", "key", "access", "api_key", "apikey", "token", "tkn"]

# Do Not store secrets in ENV variables
deny[msg] {
    input[i].Cmd == "env"
    val := input[i].Value[_]  # loop over each ENV line
    some secret
    secret := secrets_env[_]
    contains(lower(val), secret)
    msg := sprintf("Line %d: Potential secret in ENV key/value found: %s", [i, val])
}

# Do not use 'latest' tag for base image
deny[msg] {
    input[i].Cmd == "from"
    val := split(input[i].Value[0], ":")
    lower(val[1]) == "latest"
    msg := sprintf("Line %d: Do not use 'latest' tag for base images: %s", [i, input[i].Value[0]])
}

# Avoid curl | bash patterns
deny[msg] {
    input[i].Cmd == "run"
    val := concat(" ", input[i].Value)
    regex.match(`(curl|wget)\s+[^|^>]*[|]\s*(bash|sh)`, lower(val))
    msg := sprintf("Line %d: Avoid curl | bash patterns: %s", [i, val])
}

# Do not upgrade system packages in RUN
warn[msg] {
    input[i].Cmd == "run"
    val := concat(" ", input[i].Value)
    regex.match(`(apk|apt|yum|dnf|pip)\s+.*(install|upgrade|update)`, lower(val))
    msg := sprintf("Line %d: Avoid upgrading system packages in Dockerfile: %s", [i, val])
}

# Do not use sudo
deny[msg] {
    input[i].Cmd == "run"
    val := concat(" ", input[i].Value)
    contains(lower(val), "sudo")
    msg := sprintf("Line %d: Do not use 'sudo' command: %s", [i, val])
}

# Prefer multi-stage builds when using COPY
multi_stage {
    some i
    input[i].Cmd == "copy"
    some flag
    flag := input[i].Flags[_]
    starts_with(lower(flag), "--from=")
}

warn[msg] {
    not multi_stage
    some i
    input[i].Cmd == "copy"
    msg := "You use COPY but do not appear to use multi-stage builds"
}

# Any USER directive is good, but do not use root/toor/0
forbidden_users := ["root", "toor", "0", "admin"]

deny[msg] {
    some i
    input[i].Cmd == "user"
    user := lower(input[i].Value[0])
    user in forbidden_users
    msg := sprintf("Line %d: Forbidden user in USER directive: %s", [i, input[i].Value[0]])
}

# Warn if no USER directive at all (run as root by default)
warn[msg] {
    not any_user
    msg := "No USER directive found — container will run as root by default"
}

any_user {
    some i
    input[i].Cmd == "user"
}