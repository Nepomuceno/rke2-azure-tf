This project includes the Terraform configuration to deploy RKE2 in Azure in a VPN. In order to access the cluster, a VPN gateway and corresponding local OpenVPN client are also setup.


# Getting started

1. The dev environment with all the development requirements can be set up by starting the devcontainer in [.devcontainer](.devcontainer).

2. Create a service principal with `Contributor` and `Network Contributor` access to the subscription.

3. Setup the tfvars corresponding to the [Terraform variables](variables.tf).

4. Deploy the Azure resources.

```
terraform init
terraform apply --auto-approve
```

5. Setup OpenVPN client.
```
bash vpn-client.sh
```

6. (Optional) Generate kubeconfig. In should be generated by the Terraform configuration in `rke2.kubeconfig`; but the cluster may not be ready when the Terraform script tries to fetch the kubeconfig from the keyvault. In this case, the kubeconfig can be downloaded from the keyvault:
```
bash fetch-kubeconfig.sh
```


In order to ssh into the VMs, you need to use the corresponding certificate:
```
ssh -I .ssh/rk2_id_rsa rke2@<vm_ip>
```
