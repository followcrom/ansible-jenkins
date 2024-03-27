# Terraform

## What is Terraform?

Terraform is an open-source infrastructure as code software tool created by HashiCorp. It allows users to define and provision data center infrastructure using a declarative configuration language. Terraform manages external resources, such as public cloud infrastructure, private cloud infrastructure, network appliances, software as a service, and platform as a service.

## How does Terraform work?

Terraform uses a declarative configuration language to describe the desired state of your infrastructure. It then generates an execution plan that defines how to achieve that desired state. Terraform applies the execution plan to build the infrastructure.

## What are the key features of Terraform?

Some key features of Terraform include:

- Infrastructure as code: Terraform allows you to define your infrastructure as code using a declarative configuration language.
- Multi-cloud support: Terraform supports multiple cloud providers, allowing you to manage infrastructure across different cloud platforms.
- Resource management: Terraform manages the lifecycle of infrastructure resources, including creation, updating, and deletion.
- State management: Terraform keeps track of the state of your infrastructure and can be used to update or modify existing resources.
- Plan and apply: Terraform generates an execution plan that shows what will be done before making any changes to your infrastructure.

## How do you install Terraform?

To install Terraform, you can download the binary from the official Terraform website and add it to your system's PATH. Alternatively, you can use a package manager like Homebrew on macOS or Chocolatey on Windows to install Terraform.

## How do you use Terraform?

To use Terraform, you need to define your infrastructure in a Terraform configuration file using the HashiCorp Configuration Language (HCL). You then run the `terraform init` command to initialize your working directory, `terraform plan` to generate an execution plan, and `terraform apply` to apply the plan and build your infrastructure.

## What are Terraform modules?

Terraform modules are reusable packages of Terraform configurations that can be used to create and manage infrastructure resources. Modules allow you to encapsulate and share infrastructure configurations, making it easier to reuse and maintain your infrastructure code.

## Desired state vs current state

Terraform uses the concept of desired state to manage infrastructure resources. The desired state is defined in your Terraform configuration file and describes the state you want your infrastructure to be in. Terraform compares the desired state with the current state of your infrastructure and makes any necessary changes to bring the infrastructure into the desired state.

## How to run a terraform script?

To run a Terraform script, you need to define your infrastructure in a Terraform configuration file using the HashiCorp Configuration Language (HCL). You then run the `terraform init` command to initialize your working directory, `terraform plan` to generate an execution plan, and `terraform apply` to apply the plan and build your infrastructure.
