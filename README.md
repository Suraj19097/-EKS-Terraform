# EKS-Terraform
# This is Terraform configuration file to crate Terraform cluster on AWS.

# Terraform AWS Cluster

This repository contains a Terraform configuration file to create a cluster on AWS.

# Overview

This Terraform script automates the provisioning of a cluster on AWS, enabling seamless infrastructure deployment.

# Prerequisites

Before using this Terraform configuration, ensure you have:

Terraform installed (Download here)

AWS CLI installed and configured with the necessary credentials

Appropriate IAM permissions to create AWS resources

# Usage

Clone this repository:

git clone https://github.com/Suraj19097/-EKS-Terraform.git
cd -EKS-Terraform

Initialize Terraform:

terraform init

Plan the deployment:

terraform plan

Apply the configuration:

terraform apply 

Cleanup

To destroy the provisioned resources:

terraform destroy -auto-approve

# License

This project is licensed under the MIT License.


