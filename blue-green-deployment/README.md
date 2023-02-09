# Blue/Green deployments
Blue/green deployments provide releases with near zero-downtime and rollback capabilities.
# Blue/Green deployments with Autoscaling Group
<h2>Application Infrastucture</h2>

- Virtual Private Cloud (VPC).
- Application Load Balancer (ALB).
- 2 Autoscaling Group (Blue/Green).

<h3> Base resource </h3>

- VPC
- Subnet
- Internet Gateway
- ALB

<h3> Application resource </h3>

- AutoScaling Group
- Lauch Templates

<h3> Implement </h3>

Green Application
```tf
module "green" {
  source      = "./modules/autoscaling"
  app_version = "v1.0"
  label       = "green"
  base        = module.base
}
```
Deploy version 1.0
```sh
terraform apply -auto-approve
```

Adding Blue Application (ver 2.0)
```tf
...
module "blue" {
  source      = "./modules/autoscaling"
  app_version = "v2.0"
  label       = "blue"
  base        = module.base
}
```
Deploy version 2.0
```
terraform apply -auto-approve
``` 

<b>Blue/Green cutover</b>

Change value of ```production``` in ```main.tf```

```tf
variable "production" {
  default = "blue" // change here
}
```
