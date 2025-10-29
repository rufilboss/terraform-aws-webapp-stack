# Terraform AWS WebApp Stack

A comprehensive AWS infrastructure project using Terraform to deploy a scalable web application with load balancing, auto-scaling, and monitoring capabilities.

## Architecture Overview

This project creates:

- VPC with public/private subnets across multiple AZs
- Application Load Balancer (ALB) with SSL termination
- Auto Scaling Group with EC2 instances
- Route53 DNS configuration
- Security Groups and ACM certificates
- Optional WAF and monitoring (requires additional modules)

## Prerequisites

### Required Tools

- [Terraform](https://www.terraform.io/downloads.html) >= 1.5
- [AWS CLI](https://aws.amazon.com/cli/) configured with appropriate credentials
- An AWS account with necessary permissions
- A registered domain name
- Route53 hosted zone for your domain

### AWS Permissions Required

- EC2 (instances, security groups, load balancers)
- VPC (subnets, route tables, internet gateways)
- Route53 (hosted zones, records)
- ACM (certificate management)
- IAM (roles and policies)

## Quick Start

### 1. Clone and Setup

```bash
git clone https://github.com/rufilboss/terraform-aws-webapp-stack.git
cd terraform-aws-webapp-stack/terraform
```

### 2. Configure Variables

Create a `terraform.tfvars` file:

```hcl
# Required variables
domain_name = "example.com"
route53_zone_id = "Z1234567890ABC"

# Optional customizations
project_name = "my-web-app"
environment = "prod"
aws_region = "us-east-1"
instance_type = "t3.medium"
```

### 3. Initialize and Deploy

```bash
# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply the configuration
terraform apply
```

### 4. Access Your Application

After deployment, your application will be available at:

- `https://your-domain.com`
- `https://www.your-domain.com`

## Configuration Options

### Network Configuration

- `vpc_cidr`: VPC CIDR block (default: 10.0.0.0/16)
- `availability_zones`: List of AZs to use
- `public_subnet_cidrs`: Public subnet CIDR blocks
- `private_subnet_cidrs`: Private subnet CIDR blocks

### Compute Configuration

- `instance_type`: EC2 instance type (default: t3.medium)
- `min_size`: Minimum instances in ASG (default: 2)
- `max_size`: Maximum instances in ASG (default: 6)
- `desired_capacity`: Desired instances in ASG (default: 3)

### Security Configuration

- `allowed_cidr_blocks`: CIDR blocks allowed access
- `enable_waf`: Enable AWS WAF (requires WAF module)
- `enable_ssl_redirect`: Force HTTPS redirects

## Project Structure

```sh
terraform/
├── main.tf              # Main configuration
├── variables.tf         # Variable definitions
├── providers.tf         # Provider configuration
└── modules/
    ├── vpc/            # VPC and networking
    ├── sg/             # Security groups
    ├── alb/            # Application Load Balancer
    ├── ec2/            # EC2 instances and ASG
    ├── acm/            # SSL certificates
    └── route53/        # DNS configuration
```

## Important Notes

⚠️ **Current Limitations:**

- Backend state configuration is commented out (recommended to enable for production)
- Some modules may need additional configuration based on specific requirements
- WAF module is optional and only enabled when `enable_waf = true`
- Monitoring module only activates when `notification_email` is provided

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

## Troubleshooting

### Common Issues

1. **Domain validation**: Ensure your domain is registered and Route53 zone exists
2. **AWS credentials**: Verify AWS CLI is configured correctly
3. **Resource limits**: Check AWS service limits in your region
4. **Module errors**: Some referenced modules need to be implemented

### Getting Help

- Check Terraform logs: `TF_LOG=DEBUG terraform apply`
- Validate configuration: `terraform validate`
- Format code: `terraform fmt`

## Security Considerations

- Store Terraform state in S3 with encryption (uncomment backend configuration)
- Use least privilege IAM policies
- Enable VPC Flow Logs for network monitoring
- Regularly update AMIs and security patches
- Consider enabling AWS Config for compliance monitoring

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
