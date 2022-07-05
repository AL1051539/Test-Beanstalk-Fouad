#################################FROM ELASTIC BEANSTALK INSTANCE#############################
variable "m_env_solution_stack_name" {
  type        = string
  description = "The solution stack name of Elastic Beanstalk application"
}

variable "m_associate_public_ip_address" {
  type        = bool
  description = "Whether to associate public IP addresses to the instances. Defaults to `false` if no value is specified"
  default     = false
}

variable "m_app_name" {
  type        = string
  description = "A unique name for the Application to be deployed using Beanstalk"
}

variable "m_vpc_id" {
  type        = string
  description = "VPC where the Beanstalk is to be deployed"
}

variable "m_subnet_ids" {
  type        = list(string)
  description = "List of subnets to place the EC2 instances"
}

variable "m_ec2_supported_architectures" {
  type        = string
  description = <<EOF
  A comma-separated list of EC2 instance architecture types that you'll use for your environment.
  Elastic Beanstalk supports instance types based on the following processor architectures:
  - AWS Graviton 64-bit Arm architecture (`arm64`)
  - 64-bit architecture (`x86_64`)
  - 32-bit architecture (`i386`)
EOF
  default     = "x86_64"
}

variable "m_ec2_instance_type" {
  type        = string
  description = "The instance type for Elastic Beanstalk, like `t2.micro`, `m5.large`, etc."
}

variable "m_ec2_root_volume_size" {
  type        = number
  description = "A root volume with the size specified in Gigabytes (GB), where the OS will be installed when the EC2 instance is being created. Defaults to `10` GB if no value is specified"
  default     = 10
}

variable "m_tags" {
  type        = map(string)
  description = "Tags"
  default     = {}
}

variable "m_environment_tag" {
  type = string

  description = <<-EOF
  The environment name to be used while tagging the provisioned resources. The list of possible values are as follows:
  - `d` for development
  - `t` for test
  - `q` for qualification
  - `i` for integration
  - `s` for staging or pre-production
  - `p` for production
EOF
  default     = "d"

  validation {
    condition     = contains(["d", "t", "q", "i", "s", "p"], lower(var.m_environment_tag))
    error_message = "Unsupported environment tag specified. Supported environments are: 'd', 't', 'q', 'i', 's', and 'p'."
  }
}

variable "m_resource_name" {
  type        = string
  description = "Resource name"
}

variable "m_bucket" {
  type        = string
  description = "The ID of S3 bucket"
}

variable "m_object_key" {
  type        = string
  description = "The object ID of S3 bucket"
}

variable "m_cname_prefix" {
  type        = string
  description = "Prefix to use for the fully qualified DNS name of the environment"
}

variable "m_application_domain" {
  type        = string
  description = "The domain name of the application"
}

variable "m_version_label" {
  type        = string
  description = "The application version label"
  default     = ""
}

/**********************************************************/
/// IAM ROLE
/**********************************************************/

variable "m_scheme" {
  type        = string
  description = "Allows creation of an internal load balancer in the VPC in order to that Elastic Beanstalk application cannot be accessed from outside the VPC. Defaults to `internet-facing` if no value is specified"

  validation {
    condition     = contains(["internet-facing", "internal"], var.m_scheme)
    error_message = "Unsupported scheme type tag specified. Supported types are: 'internet-facing' and 'internal'."
  }

  default = "internet-facing"
}

### Log Group module information
variable "m_logs_retention_in_days" {
  type        = number
  description = "The number of days for the log group to retain the metrics and logs. Defaults to '90' days"
  default     = 90
}

variable "m_logs_delete_on_terminate" {
  type        = bool
  description = "Whether to delete the log groups when the environment is terminated. If `false`, the logs are kept for the number of days specified by the variable `m_logs_retention_in_days`. Defaults to `false` if no value is specified"
  default     = false
}

variable "m_delete_on_terminate" {
  type        = bool
  description = "Whether to delete the log groups when the environment is terminated. If `false`, the logs are kept for the number of days specified by the variable `m_logs_retention_in_days`. Defaults to `false` if no value is specified"
  default     = false
}

variable "m_tier" {
  type        = string
  description = "Elastic Beanstalk Environment tier. Valid values are `WebServer` or `Worker`. Defaults to `WebServer` if no value is specified"
  default     = "WebServer"
}

variable "m_wait_for_ready_timeout" {
  type        = string
  description = "The maximum duration to wait for the Elastic Beanstalk Environment to be in a ready state before timing out Defaults to `20m` if no value is specified"
  default     = "20m"
}

variable "m_enhanced_reporting_enabled" {
  type        = bool
  description = <<-EOF
  Whether to enable `enhanced` health reporting for this environment. If `false`, `basic` reporting is used.
  **Important**: When set to `false`, you must also set `enable_managed_actions` to `false`.

  Defaults to `true` if no value is specified.
EOF
  default     = true
}

variable "m_managed_actions_enabled" {
  type        = bool
  description = "Enable managed platform updates. When you set this to true, you must also specify a `PreferredStartTime` and `UpdateLevel`. Defaults to `false` if no value is specified"
  default     = false
}

variable "m_preferred_start_time" {
  type        = string
  description = "Configure a maintenance window for managed actions in UTC timezone. Defaults to `Sun:10:00` if no value is specified"
  default     = "Sun:10:00"
}

variable "m_update_level" {
  type        = string
  description = "The highest level of update to apply with managed platform updates. Defaults to `minor` if no value is specified"
  default     = "minor"
}

variable "m_availability_zone_selector" {
  type        = string
  description = "Availability Zone selector. Defaults to `Any 2` if no value is specified"
  default     = "Any 2"
}

variable "m_prefer_legacy_service_policy" {
  type        = bool
  description = "Whether to use `AWSElasticBeanstalkService` (deprecated) or `AWSElasticBeanstalkManagedUpdatesCustomerRolePolicy` policy. Defaults to `false`, i.e. uses the `AWSElasticBeanstalkManagedUpdatesCustomerRolePolicy` policy, if no value is specified"
  default     = false
}

variable "m_enable_stream_logs" {
  type        = bool
  description = "Whether to create groups in CloudWatch Logs for proxy and deployment logs, and stream logs from each instance in your environment"
  default     = false
}

variable "m_enable_log_publication_control" {
  type        = bool
  description = "Copy the log files for your application's Amazon EC2 instances to the Amazon S3 bucket associated with your application"
  default     = false
}

variable "m_autoscale_min" {
  type        = number
  description = "Minumum instances to launch"
  default     = 1
}

variable "m_autoscale_max" {
  type        = number
  description = "Maximum instances to launch"
  default     = 2
}

variable "m_environment_type" {
  type        = string
  description = "Environment type, e.g. 'LoadBalanced' or 'SingleInstance'.  If setting to 'SingleInstance', `rolling_update_type` must be set to 'Time', `updating_min_in_service` must be set to 0, and `loadbalancer_subnets` will be unused (it applies to the ELB, which does not exist in SingleInstance environments)"

  validation {
    condition     = contains(["LoadBalanced", "SingleInstance"], var.m_environment_type)
    error_message = "Unsupported environment type tag specified. Supported types are: 'LoadBalanced' and 'SingleInstance'."
  }

  default = "LoadBalanced"
}

variable "m_rolling_update_enabled" {
  type        = bool
  description = "Whether to enable rolling update"
  default     = true
}

variable "m_rolling_update_type" {
  type        = string
  description = "`Health` or `Immutable`. Set it to `Immutable` to apply the configuration change to a fresh group of instances"

  validation {
    condition     = contains(["Health", "Immutable"], var.m_rolling_update_type)
    error_message = "Unsupported rolling update type tag specified. Supported types are: 'Health' and 'Immutable'."
  }

  default = "Health"
}

variable "m_updating_min_in_service" {
  type        = number
  description = "Minimum number of instances in service during update"
  default     = 1
}

variable "m_updating_max_batch" {
  type        = number
  description = "Maximum number of instances to update at once"
  default     = 2
}

variable "m_vpc_security_group_ids" {
  type        = list(string)
  description = "A list of Security Group IDs to associate with EC2 instances"
}

variable "m_alb_security_group_ids" {
  type        = list(string)
  description = "A list of Security Group IDs to associate with EC2 instances"
}

variable "m_elb_arn" {
  type        = string
  description = "Allows to attach AWS LoadBalancer to the Beanstalk"
}

variable "m_certificate_arn" {
  type        = string
  description = "The ARN of the certificate"
}

#====================================HEALTH CHECK==================================#
variable "m_health_streaming_enabled" {
  type        = bool
  description = "For environments with enhanced health reporting enabled, whether to create a group in CloudWatch Logs for environment health and archive Elastic Beanstalk environment health data. For information about enabling enhanced health, see aws:elasticbeanstalk:healthreporting:system."
  default     = false
}

variable "m_health_streaming_delete_on_terminate" {
  type        = bool
  description = "Whether to delete the log group when the environment is terminated. If false, the health data is kept RetentionInDays days."
  default     = false
}

variable "m_health_streaming_retention_in_days" {
  type        = number
  description = "The number of days to keep the archived health data before it expires."
  default     = 7
}

variable "m_environment_variables" {
  type        = list(map(string))
  description = <<EOF
  List of key-value pairs which will be used to setup the environment variables, which will then be used by
  the application from within the Beanstalk's EC2 environment, e.g.:

  ```
  [
    {
      name  = "SERVER_PORT"
      value = "5000"
    },
    {
      name  = "ADMIN_PORT"
      value = "9000"
    }
  ]
  ```

  **Important**: The namespace for these environment variable is limited to only `aws:elasticbeanstalk:application:environment`.
  For further info on these options, please refer here: https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/command-options-general.html.

  Defaults to an empty list `[]` if no value is provided.
EOF

  default = []
}

variable "m_custom_alb_rules" {
  type        = string
  description = "list that start and is separated with ',' containing the custom rules names "
  default     = ""
}

variable "m_additional_configurations" {
  type        = list(map(string))
  description = <<EOF
  List of key-value pairs which will be used to setup any application specific configurations that are not
  already provided in the Beanstalk module. For example: Certain applications may need to configure an external
  EBS volume and attach it to the EC2 instance being created by Beanstalk, or to use an EC2 key-pair for securely
  logging into the instance, etc. Therefore, to provide this EBS volume information and to add a EC2 key-pair,
  the following example maybe used:

  ```
  [
    {
      namespace = "aws:autoscaling:launchconfiguration"
      name      = "BlockDeviceMappings"
      value     = "/dev/sdj=:100:true:gp2,/dev/sdh=snap-faef1251"
    },
    {
      namespace = "aws:autoscaling:launchconfiguration"
      name      = "EC2KeyName"
      value     = "my-ec2-key-pair"
    }
  ]
  ```

  **Important**: The `namespace` values are limited to the AWS provided command options, available here: https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/command-options-general.html

  Defaults to an empty list `[]` if no value is provided.
EOF

  default = []
}

