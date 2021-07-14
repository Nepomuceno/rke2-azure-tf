This project includes the Terraform configuration to deploy an RKE2 cluster in Azure

# Getting Started

1. The dev environment with all the development requirements can be set up by starting the devcontainer in [.devcontainer](.devcontainer).

2. Copy `sample.tfvars` to your own copy e.g. `mycluster.tfvars` modify variables to suit your deployment, such as region and which Azure cloud to use, you will probably want to change the `cluster_name` as well.

3. Deploy the RKE2 cluster with:

    ```bash
    terraform init
    terraform apply --auto-approve
    ```

# Connecting to RKE2

This section assumes you have a publicly accessible cluster, i.e. you have set `server_public_ip` to true

A script is provided to download the kubeconfig file needed to access the cluster, from KeyVault to the local machine, it also sets KUBECONFIG to point to the new kubeconfig

```bash
source scripts/fetch-kubeconfig.sh
```

> **Note.** You must source the script, also you may have to wait for a minute or two after deploying the cluster before the kubeconfig is ready

Now you can run kubectl commands against the cluster as normal, e.g. `kubectl get nodes` or `kubectl get pods -A` to see the status and health of the cluster.

# SSH to Servers (Control Plane)

If you set `server_open_ssh_public` to true, then SSH will be allowed onto the server nodes, through the control plane load balancer. 

> Note. This is only recommended when troubleshooting RKE2 itself, and associated configuration such as the Azure cloud provider. For normal operation SSH access is not required.

This is done with a Azure Load Balancer NAT pool, the pool maps ports from 5000 onwards to port 22 on each of the instances, e.g.

- Port 5000 -> port 22 on instance 0
- Port 5001 -> port 22 on instance 1
- Port 5002 -> port 22 on instance 2
- etc

A script is provided that will download the SSH private key from KeyVault and tell you the public IP you need to use. The SSH username is `rke2`

```bash
./scripts/fetch-ssh-key.sh
```

> **Note.** For reasons unknown sometimes the scale set takes some time to settle down, and even with a single instance, it might not be instance 0, it can be 1 or even 2, so try ports 5001 and 5002 if 5000 doesn't work