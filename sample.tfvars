# Which Azure cloud to use
cloud = "AzureUSGovernmentCloud"

# Which Azure region to deploy into
location = "usgovvirginia"

# Prefix used for all resources
cluster_name = "rke2-cluster"

# Assign a public IP to the control plane load balancer
server_public_ip = true

# Allow SSH to the server nodes through the control plane load balancer
server_open_ssh_public = false
