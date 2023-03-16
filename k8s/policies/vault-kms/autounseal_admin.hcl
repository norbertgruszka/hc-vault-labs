path "transit/keys" {
    capabilities = ["read", "create", "delete", "update", "patch", "list"]
}

path "transit/keys/*" {
    capabilities = ["read", "create", "delete", "update", "patch", "list"]
}