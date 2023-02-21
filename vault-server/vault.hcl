ui = true

storage "file" {
  path = "/home/vault/data"
}


listener "tcp" {
  address = "0.0.0.0:8200"
  cluster_address = "0.0.0.0:8200" 
  tls_disable = 1
}

