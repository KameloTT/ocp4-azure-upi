## OCP 4.1 deployment on Azure Cloud using User provisioned Infrastructure

### Architecture:

When using this method, you can: <br>
  * Specify the number of masters and workers you want to provision<br>
  * Change Network Security Group rules in order to lock down the ingress access to the cluster<br>
  * Change Infrastructure component names<br>
  * Add tags

This Terraform based aproach will split VMs accross 3 Azure Availability Zones and will use 2 Zone Redundant Load Balancers (1 Public facing to serve OCP routers and api and 1 Private to serve api-int)<br>

Please see the topology bellow:
![Openshift Container Platform 4.1 Topology on Azure](./images/diagram.svg)

Deployment can be split into 4 steps:
 * Create Control Plane (masters) and Surrounding Infrastructure (LB,DNS,VNET etc.)
 * Destroy Bootstrap VM
 * Set the default Ingress controller to type HostNetwork
 * Create Compute (worker) nodes

### Prereqs:

This method uses the following tools:<br>
  * terraform >= 0.12<br>
  * openshift-cli<br>
  * git<br>
  * jq (optional)
  
  NOTE: Free Trial account is not enough and Pay As You Go is recommended with increased quota for vCPU:<br>
  https://blogs.msdn.microsoft.com/girishp/2015/09/20/increasing-core-quota-limits-in-azure/

### Preparation

1. Prepare Azure Cloud for Openshift installation:<br>
https://github.com/openshift/installer/tree/master/docs/user/azure

You need to follow this Installation section as well:<br>
https://github.com/openshift/installer/blob/d0f7654bc4a0cf73392371962aef68cd9552b5dd/docs/user/azure/install.md

2. Clone this repository

```sh
  $> git clone https://github.com/KameloTT/ocp4-azure-upi.git
  $> cd ocp4-azure-upi
  $> git checkout custom-ipi
```

3. Initialize Terraform working directories (current and worker):

```sh
$> terraform init
$> cd ../
```
4. Todo
