# aws-iac-module-elastic-beanstalk

Details of the Elastic Beanstalk can be referenced [here](https://aws.amazon.com/elasticbeanstalk/?nc1=h_ls). Below are excerpts of the same.

AWS Elastic Beanstalk is an easy-to-use service for deploying and scaling web applications and services developed with Java, .NET, PHP, Node.js, Python, Ruby, Go, and Docker on familiar servers such as Apache, Nginx, Passenger, and IIS.

You can simply upload your code and Elastic Beanstalk automatically handles the deployment, from capacity provisioning, load balancing, auto-scaling to application health monitoring. At the same time, you retain full control over the AWS resources powering your application and can access the underlying resources at any time.

There is no additional charge for Elastic Beanstalk - you pay only for the AWS resources needed to store and run your applications.


---

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 3.74.3 |

---

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_m_additional_configurations"></a> [m\_additional\_configurations](#input\_m\_additional\_configurations) | List of key-value pairs which will be used to setup any application specific configurations that are not<br>  already provided in the Beanstalk module. For example: Certain applications may need to configure an external<br>  EBS volume and attach it to the EC2 instance being created by Beanstalk, or to use an EC2 key-pair for securely<br>  logging into the instance, etc. Therefore, to provide this EBS volume information and to add a EC2 key-pair,<br>  the following example maybe used:<pre>[<br>    {<br>      namespace = "aws:autoscaling:launchconfiguration"<br>      name      = "BlockDeviceMappings"<br>      value     = "/dev/sdj=:100:true:gp2,/dev/sdh=snap-faef1251"<br>    },<br>    {<br>      namespace = "aws:autoscaling:launchconfiguration"<br>      name      = "EC2KeyName"<br>      value     = "my-ec2-key-pair"<br>    }<br>  ]</pre>**Important**: The `namespace` values are limited to the AWS provided command options, available here: https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/command-options-general.html<br><br>  Defaults to an empty list `[]` if no value is provided. | `list(map(string))` | `[]` | no |
| <a name="input_m_alb_security_group_ids"></a> [m\_alb\_security\_group\_ids](#input\_m\_alb\_security\_group\_ids) | A list of Security Group IDs to associate with EC2 instances | `list(string)` | n/a | yes |
| <a name="input_m_app_name"></a> [m\_app\_name](#input\_m\_app\_name) | A unique name for the Application to be deployed using Beanstalk | `string` | n/a | yes |
| <a name="input_m_application_domain"></a> [m\_application\_domain](#input\_m\_application\_domain) | The domain name of the application | `string` | n/a | yes |
| <a name="input_m_associate_public_ip_address"></a> [m\_associate\_public\_ip\_address](#input\_m\_associate\_public\_ip\_address) | Whether to associate public IP addresses to the instances. Defaults to `false` if no value is specified | `bool` | `false` | no |
| <a name="input_m_autoscale_max"></a> [m\_autoscale\_max](#input\_m\_autoscale\_max) | Maximum instances to launch | `number` | `2` | no |
| <a name="input_m_autoscale_min"></a> [m\_autoscale\_min](#input\_m\_autoscale\_min) | Minumum instances to launch | `number` | `1` | no |
| <a name="input_m_availability_zone_selector"></a> [m\_availability\_zone\_selector](#input\_m\_availability\_zone\_selector) | Availability Zone selector. Defaults to `Any 2` if no value is specified | `string` | `"Any 2"` | no |
| <a name="input_m_bucket"></a> [m\_bucket](#input\_m\_bucket) | The ID of S3 bucket | `string` | n/a | yes |
| <a name="input_m_certificate_arn"></a> [m\_certificate\_arn](#input\_m\_certificate\_arn) | The ARN of the certificate | `string` | n/a | yes |
| <a name="input_m_cname_prefix"></a> [m\_cname\_prefix](#input\_m\_cname\_prefix) | Prefix to use for the fully qualified DNS name of the environment | `string` | n/a | yes |
| <a name="input_m_custom_alb_rules"></a> [m\_custom\_alb\_rules](#input\_m\_custom\_alb\_rules) | list that start and is separated with ',' containing the custom rules names | `string` | `""` | no |
| <a name="input_m_delete_on_terminate"></a> [m\_delete\_on\_terminate](#input\_m\_delete\_on\_terminate) | Whether to delete the log groups when the environment is terminated. If `false`, the logs are kept for the number of days specified by the variable `m_logs_retention_in_days`. Defaults to `false` if no value is specified | `bool` | `false` | no |
| <a name="input_m_ec2_instance_type"></a> [m\_ec2\_instance\_type](#input\_m\_ec2\_instance\_type) | The instance type for Elastic Beanstalk, like `t2.micro`, `m5.large`, etc. | `string` | n/a | yes |
| <a name="input_m_ec2_root_volume_size"></a> [m\_ec2\_root\_volume\_size](#input\_m\_ec2\_root\_volume\_size) | A root volume with the size specified in Gigabytes (GB), where the OS will be installed when the EC2 instance is being created. Defaults to `10` GB if no value is specified | `number` | `10` | no |
| <a name="input_m_ec2_supported_architectures"></a> [m\_ec2\_supported\_architectures](#input\_m\_ec2\_supported\_architectures) | A comma-separated list of EC2 instance architecture types that you'll use for your environment.<br>  Elastic Beanstalk supports instance types based on the following processor architectures:<br>  - AWS Graviton 64-bit Arm architecture (`arm64`)<br>  - 64-bit architecture (`x86_64`)<br>  - 32-bit architecture (`i386`) | `string` | `"x86_64"` | no |
| <a name="input_m_elb_arn"></a> [m\_elb\_arn](#input\_m\_elb\_arn) | Allows to attach AWS LoadBalancer to the Beanstalk | `string` | n/a | yes |
| <a name="input_m_enable_log_publication_control"></a> [m\_enable\_log\_publication\_control](#input\_m\_enable\_log\_publication\_control) | Copy the log files for your application's Amazon EC2 instances to the Amazon S3 bucket associated with your application | `bool` | `false` | no |
| <a name="input_m_enable_stream_logs"></a> [m\_enable\_stream\_logs](#input\_m\_enable\_stream\_logs) | Whether to create groups in CloudWatch Logs for proxy and deployment logs, and stream logs from each instance in your environment | `bool` | `false` | no |
| <a name="input_m_enhanced_reporting_enabled"></a> [m\_enhanced\_reporting\_enabled](#input\_m\_enhanced\_reporting\_enabled) | Whether to enable `enhanced` health reporting for this environment. If `false`, `basic` reporting is used.<br>**Important**: When set to `false`, you must also set `enable_managed_actions` to `false`.<br><br>Defaults to `true` if no value is specified. | `bool` | `true` | no |
| <a name="input_m_env_solution_stack_name"></a> [m\_env\_solution\_stack\_name](#input\_m\_env\_solution\_stack\_name) | The solution stack name of Elastic Beanstalk application | `string` | n/a | yes |
| <a name="input_m_environment_tag"></a> [m\_environment\_tag](#input\_m\_environment\_tag) | The environment name to be used while tagging the provisioned resources. The list of possible values are as follows:<br>- `d` for development<br>- `t` for test<br>- `q` for qualification<br>- `i` for integration<br>- `s` for staging or pre-production<br>- `p` for production | `string` | `"d"` | no |
| <a name="input_m_environment_type"></a> [m\_environment\_type](#input\_m\_environment\_type) | Environment type, e.g. 'LoadBalanced' or 'SingleInstance'.  If setting to 'SingleInstance', `rolling_update_type` must be set to 'Time', `updating_min_in_service` must be set to 0, and `loadbalancer_subnets` will be unused (it applies to the ELB, which does not exist in SingleInstance environments) | `string` | `"LoadBalanced"` | no |
| <a name="input_m_environment_variables"></a> [m\_environment\_variables](#input\_m\_environment\_variables) | List of key-value pairs which will be used to setup the environment variables, which will then be used by<br>  the application from within the Beanstalk's EC2 environment, e.g.:<pre>[<br>    {<br>      name  = "SERVER_PORT"<br>      value = "5000"<br>    },<br>    {<br>      name  = "ADMIN_PORT"<br>      value = "9000"<br>    }<br>  ]</pre>**Important**: The namespace for these environment variable is limited to only `aws:elasticbeanstalk:application:environment`.<br>  For further info on these options, please refer here: https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/command-options-general.html.<br><br>  Defaults to an empty list `[]` if no value is provided. | `list(map(string))` | `[]` | no |
| <a name="input_m_health_streaming_delete_on_terminate"></a> [m\_health\_streaming\_delete\_on\_terminate](#input\_m\_health\_streaming\_delete\_on\_terminate) | Whether to delete the log group when the environment is terminated. If false, the health data is kept RetentionInDays days. | `bool` | `false` | no |
| <a name="input_m_health_streaming_enabled"></a> [m\_health\_streaming\_enabled](#input\_m\_health\_streaming\_enabled) | For environments with enhanced health reporting enabled, whether to create a group in CloudWatch Logs for environment health and archive Elastic Beanstalk environment health data. For information about enabling enhanced health, see aws:elasticbeanstalk:healthreporting:system. | `bool` | `false` | no |
| <a name="input_m_health_streaming_retention_in_days"></a> [m\_health\_streaming\_retention\_in\_days](#input\_m\_health\_streaming\_retention\_in\_days) | The number of days to keep the archived health data before it expires. | `number` | `7` | no |
| <a name="input_m_logs_delete_on_terminate"></a> [m\_logs\_delete\_on\_terminate](#input\_m\_logs\_delete\_on\_terminate) | Whether to delete the log groups when the environment is terminated. If `false`, the logs are kept for the number of days specified by the variable `m_logs_retention_in_days`. Defaults to `false` if no value is specified | `bool` | `false` | no |
| <a name="input_m_logs_retention_in_days"></a> [m\_logs\_retention\_in\_days](#input\_m\_logs\_retention\_in\_days) | The number of days for the log group to retain the metrics and logs. Defaults to '90' days | `number` | `90` | no |
| <a name="input_m_managed_actions_enabled"></a> [m\_managed\_actions\_enabled](#input\_m\_managed\_actions\_enabled) | Enable managed platform updates. When you set this to true, you must also specify a `PreferredStartTime` and `UpdateLevel`. Defaults to `false` if no value is specified | `bool` | `false` | no |
| <a name="input_m_object_key"></a> [m\_object\_key](#input\_m\_object\_key) | The object ID of S3 bucket | `string` | n/a | yes |
| <a name="input_m_prefer_legacy_service_policy"></a> [m\_prefer\_legacy\_service\_policy](#input\_m\_prefer\_legacy\_service\_policy) | Whether to use `AWSElasticBeanstalkService` (deprecated) or `AWSElasticBeanstalkManagedUpdatesCustomerRolePolicy` policy. Defaults to `false`, i.e. uses the `AWSElasticBeanstalkManagedUpdatesCustomerRolePolicy` policy, if no value is specified | `bool` | `false` | no |
| <a name="input_m_preferred_start_time"></a> [m\_preferred\_start\_time](#input\_m\_preferred\_start\_time) | Configure a maintenance window for managed actions in UTC timezone. Defaults to `Sun:10:00` if no value is specified | `string` | `"Sun:10:00"` | no |
| <a name="input_m_resource_name"></a> [m\_resource\_name](#input\_m\_resource\_name) | Resource name | `string` | n/a | yes |
| <a name="input_m_rolling_update_enabled"></a> [m\_rolling\_update\_enabled](#input\_m\_rolling\_update\_enabled) | Whether to enable rolling update | `bool` | `true` | no |
| <a name="input_m_rolling_update_type"></a> [m\_rolling\_update\_type](#input\_m\_rolling\_update\_type) | `Health` or `Immutable`. Set it to `Immutable` to apply the configuration change to a fresh group of instances | `string` | `"Health"` | no |
| <a name="input_m_scheme"></a> [m\_scheme](#input\_m\_scheme) | Allows creation of an internal load balancer in the VPC in order to that Elastic Beanstalk application cannot be accessed from outside the VPC. Defaults to `internet-facing` if no value is specified | `string` | `"internet-facing"` | no |
| <a name="input_m_subnet_ids"></a> [m\_subnet\_ids](#input\_m\_subnet\_ids) | List of subnets to place the EC2 instances | `list(string)` | n/a | yes |
| <a name="input_m_tags"></a> [m\_tags](#input\_m\_tags) | Tags | `map(string)` | `{}` | no |
| <a name="input_m_tier"></a> [m\_tier](#input\_m\_tier) | Elastic Beanstalk Environment tier. Valid values are `WebServer` or `Worker`. Defaults to `WebServer` if no value is specified | `string` | `"WebServer"` | no |
| <a name="input_m_update_level"></a> [m\_update\_level](#input\_m\_update\_level) | The highest level of update to apply with managed platform updates. Defaults to `minor` if no value is specified | `string` | `"minor"` | no |
| <a name="input_m_updating_max_batch"></a> [m\_updating\_max\_batch](#input\_m\_updating\_max\_batch) | Maximum number of instances to update at once | `number` | `2` | no |
| <a name="input_m_updating_min_in_service"></a> [m\_updating\_min\_in\_service](#input\_m\_updating\_min\_in\_service) | Minimum number of instances in service during update | `number` | `1` | no |
| <a name="input_m_version_label"></a> [m\_version\_label](#input\_m\_version\_label) | The application version label | `string` | `""` | no |
| <a name="input_m_vpc_id"></a> [m\_vpc\_id](#input\_m\_vpc\_id) | VPC where the Beanstalk is to be deployed | `string` | n/a | yes |
| <a name="input_m_vpc_security_group_ids"></a> [m\_vpc\_security\_group\_ids](#input\_m\_vpc\_security\_group\_ids) | A list of Security Group IDs to associate with EC2 instances | `list(string)` | n/a | yes |
| <a name="input_m_wait_for_ready_timeout"></a> [m\_wait\_for\_ready\_timeout](#input\_m\_wait\_for\_ready\_timeout) | The maximum duration to wait for the Elastic Beanstalk Environment to be in a ready state before timing out Defaults to `20m` if no value is specified | `string` | `"20m"` | no |

---

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ec2_instance_role_name"></a> [ec2\_instance\_role\_name](#output\_ec2\_instance\_role\_name) | EC2 Instance IAM role name, allow to add other application policies |
| <a name="output_elastic_beanstalk_application"></a> [elastic\_beanstalk\_application](#output\_elastic\_beanstalk\_application) | The Elastic Beanstalk Application specified for this environment |
| <a name="output_elastic_beanstalk_autoscaling_groups"></a> [elastic\_beanstalk\_autoscaling\_groups](#output\_elastic\_beanstalk\_autoscaling\_groups) | The Elastic Beanstalk autoscaling\_groups for this environment |
| <a name="output_elastic_beanstalk_cname"></a> [elastic\_beanstalk\_cname](#output\_elastic\_beanstalk\_cname) | The Elastic Beanstalk CNAME for this environment |
| <a name="output_elastic_beanstalk_dns_name"></a> [elastic\_beanstalk\_dns\_name](#output\_elastic\_beanstalk\_dns\_name) | The URL to the Load Balancer for this Environment |
| <a name="output_elastic_beanstalk_id"></a> [elastic\_beanstalk\_id](#output\_elastic\_beanstalk\_id) | ID of the Elastic Beanstalk environment |
| <a name="output_elastic_beanstalk_instances"></a> [elastic\_beanstalk\_instances](#output\_elastic\_beanstalk\_instances) | The Elastic Beanstalk instances for this environment |
| <a name="output_elastic_beanstalk_name"></a> [elastic\_beanstalk\_name](#output\_elastic\_beanstalk\_name) | Name of the Elastic Beanstalk environment |

---

## Examples

```hcl
module "ebs" {
  source = "git@github.com:TotalEnergies/aws-iac-module-elastic-beanstalk.git?ref=v1.0.1"

  eb_app_version = "1.0.0"
  m_eb_access_level_actions = [
    "cloudwatch:PutMetricData",
    "ec2:DescribeInstanceStatus",
    "ssm:*",
    "ec2messages:*",
    "s3:*",
    "sqs:*",
    "elasticbeanstalk:*"
  ]
  m_eb_app_name                = "AMR Portal"
  m_eb_bucket                  = "ebsbucket-eu-central-1-01234567"
  m_eb_delete_on_terminate     = false
  m_eb_ec2_instance_port       = 5000
  m_eb_ec2_instance_type       = "t2.micro"
  m_eb_ec2_profile_role        = "event-driven-profile"
  m_eb_env_solution_stack_name = "64bit Amazon Linux 2 v3.2.8 running Corretto 11"
  m_eb_managed_policy_arns = [
    "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier",
    "arn:aws:iam::aws:policy/AWSElasticBeanstalkMulticontainerDocker",
    "arn:aws:iam::aws:policy/AWSElasticBeanstalkWorkerTier",
    "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilderECRContainerBuilds",
    "arn:aws:iam::aws:policy/AWSElasticBeanstalkManagedUpdatesCustomerRolePolicy",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]
  m_eb_object_key    = "README.md"
  path               = "/workload/"
  m_eb_resource_name = "AMR"
  m_eb_role_arn = [
    "elasticbeanstalk.amazonaws.com",
    "ec2.amazonaws.com",
    "autoscaling.amazonaws.com",
    "elasticloadbalancing.amazonaws.com",
    "ecs.amazonaws.com",
    "cloudformation.amazonaws.com"
  ]
  m_eb_security_groups = ["sg-09c820a54d87f1bc3"]
  m_eb_subnet_ids      = ["subnet-08d748064e4b7a393", "subnet-089341e8e88a9d452"]
  m_eb_version_label   = "Elastic Beanstalk Application version to deploy"
  m_eb_vpc_id          = "vpc-0f97f69ab878301ed"
}

```
