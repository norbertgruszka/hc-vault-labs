path "sys/policy" {
    capabilities = ["read", "create", "delete", "update", "patch", "list"]
}

path "sys/policy/*" {
    capabilities = ["read", "create", "delete", "update", "patch", "list"]
}