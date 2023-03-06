# HashiCorp Vault Labs

This lab was prepared with HashiCorp Vault Operations Professional exam in mind. Because I wanted to deploy multiple Vault instances I've decided to use Kubernetes. This setup is definietely not suited for a production environment and no one should even try to accomodate it to it. It was made purely for a learning purpose. I choosed Kubernetes as a platform for running docker containers since it provides a reach network configuration already in place, so I can focus on setting up Vault. 

# Start lab 

## Kubernetes 

We need to have a platform to deploy all the docker containers, so let's start by getting a Kubernetes cluster. You can use already exisitng cluster if you have one, but for those who don't here's a short command how to do it with kind
```bash 
kind create cluster --config kind-config.yml
```

