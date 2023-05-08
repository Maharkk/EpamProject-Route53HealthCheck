# EpamProject-Route53HealthCheck

This git repository uses Terraform to implement Route 53 health checks on private resources within a VPC, 
using AWS Lambda and CloudWatch. It enables efficient monitoring of resource health and easy deployment in an AWS environment.

## Prerequisites

Before you can use this code, you must have the following:

- An AWS account
- Terraform installed on your local machine
- AWS CLI installed on your local machine

## Usage

To use this code, follow these steps:

1. Clone this repository to your local machine:

```bash
git clone https://github.com/yourusername/EpamProject-Route53HealthCheck.git
```

2. Open the `main.tf` file in a text editor and replace the placeholder values with your own:

   - `aws_region`: The AWS region where you want to create the resources.
   - `vpc_id`: The ID of the VPC where your private resource is located.
   - `private_ip`: The IP address of the private resource you want to perform health checks on.
   - `health_check_interval`: The interval at which the health check should be performed, in seconds.

3. Save the `main.tf` file.

4. Navigate to the `lambda` folder and install the required dependencies:

```bash
cd lambda
npm install
```

5. Zip the contents of the `lambda` folder:

6. Initialize Terraform:

```bash
terraform init
```

7. Plan the changes to be made:

```bash
terraform plan
```

8. Apply the changes:

```bash
terraform apply
```

## Conclusion

This repository provides a quick and easy way to set up health checks on private resources in a VPC using Route53 and CloudWatch with AWS Lambda and Terraform. With just a few simple steps, you can ensure that your resources are always healthy and available.
