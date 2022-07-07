locals {
  app_label = "aws${var.m_environment_tag}-beanstalk-${var.m_app_name}-${var.m_resource_name}"
}

resource "aws_elastic_beanstalk_application" "eb_app" {
  name = var.m_app_name
  tags = merge(var.m_tags)
}

resource "aws_elastic_beanstalk_application_version" "eb_version" {
  name        = var.m_app_name
  application = aws_elastic_beanstalk_application.eb_app.id
  description = "Application version created by terraform"
  key         = var.m_object_key
  bucket      = var.m_bucket
  tags        = merge(var.m_tags)
}

resource "aws_elastic_beanstalk_environment" "eb_env" {
  name                   = "${var.m_app_name}-env"
  application            = aws_elastic_beanstalk_application.eb_app.name
  description            = "Beanstalk environment for '${local.app_label}'"
  tier                   = var.m_tier
  solution_stack_name    = var.m_env_solution_stack_name
  wait_for_ready_timeout = var.m_wait_for_ready_timeout
  cname_prefix           = var.m_cname_prefix
  version_label          = var.m_version_label == null || var.m_version_label == "" ? aws_elastic_beanstalk_application_version.eb_version.id : var.m_version_label

  tags = merge(var.m_tags)

  dynamic "setting" {
    for_each = var.m_environment_variables
    content {
      namespace = "aws:elasticbeanstalk:application:environment"
      name      = lookup(setting.value, "name", "")
      value     = lookup(setting.value, "value", "")
    }
  }

  ### If any application specific configurations are required, the following dynamic block can be used to setup
  ### the namespace, name and values, which will then be used by Beanstalk when creating the environment
  dynamic "setting" {
    for_each = var.m_additional_configurations
    content {
      namespace = lookup(setting.value, "namespace", "")
      name      = lookup(setting.value, "name", "")
      value     = lookup(setting.value, "value", "")
    }
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = var.m_vpc_id
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "AssociatePublicIpAddress"
    value     = var.m_associate_public_ip_address
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = join(",", sort(var.m_subnet_ids))
  }

  setting {
    namespace = "aws:ec2:instances"
    name      = "InstanceTypes"
    value     = var.m_ec2_instance_type
  }

  setting {
    namespace = "aws:ec2:instances"
    name      = "SupportedArchitectures"
    value     = var.m_ec2_supported_architectures
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "SecurityGroups"
    value     = join(",", sort(var.m_vpc_security_group_ids))
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "RootVolumeSize"
    value     = var.m_ec2_root_volume_size
  }

  setting {
    namespace = "aws:elbv2:loadbalancer"
    name      = "SecurityGroups"
    value     = join(",", sort(var.m_alb_security_group_ids))
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = module.ec2_role.iam_instance_profile
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "EnvironmentType"
    value     = var.m_environment_type
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "ServiceRole"
    value     = module.beanstalk_role.iam_role_arn
  }

  setting {
    namespace = "aws:elasticbeanstalk:healthreporting:system"
    name      = "SystemType"
    value     = var.m_enhanced_reporting_enabled ? "enhanced" : "basic"
  }

  setting {
    namespace = "aws:elasticbeanstalk:managedactions"
    name      = "ManagedActionsEnabled"
    value     = var.m_managed_actions_enabled
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "Availability Zones"
    value     = var.m_availability_zone_selector
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MinSize"
    value     = var.m_autoscale_min
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MaxSize"
    value     = var.m_autoscale_max
  }

  setting {
    namespace = "aws:autoscaling:updatepolicy:rollingupdate"
    name      = "RollingUpdateEnabled"
    value     = var.m_rolling_update_enabled
  }

  setting {
    namespace = "aws:autoscaling:updatepolicy:rollingupdate"
    name      = "RollingUpdateType"
    value     = var.m_rolling_update_type
  }

  setting {
    namespace = "aws:autoscaling:updatepolicy:rollingupdate"
    name      = "MinInstancesInService"
    value     = var.m_updating_min_in_service
  }

  setting {
    namespace = "aws:autoscaling:updatepolicy:rollingupdate"
    name      = "MaxBatchSize"
    value     = var.m_updating_max_batch
  }

  #=====================================AUTOSCALE TRIGGER======================================#

  # If Scheme is internet-facing, the load balancer has a public DNS name that resolves to a public IP address.
  # If Scheme is internal, the load balancer has a public DNS name that resolves to a private IP address.
  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBScheme"
    value     = var.m_scheme
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "LoadBalancerIsShared"
    value     = "true"
  }

  setting {
    namespace = "aws:elbv2:loadbalancer"
    name      = "SharedLoadBalancer"
    value     = var.m_elb_arn
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "LoadBalancerType"
    value     = "application"
  }

  setting {
    namespace = "aws:elbv2:listenerrule:domain"
    name      = "HostHeaders"
    value     = var.m_application_domain
  }

  setting {
    namespace = "aws:elbv2:listener:443"
    name      = "Rules"
    # Setting the default value here prevent
    # the default rule from being created in the ALB's HTTP:80 listener
    # Instead the default rule will be created in the HTTPS:443 listener
    value = "default,domain${var.m_custom_alb_rules}"
  }

  setting {
    namespace = "aws:elbv2:listener:443"
    name      = "DefaultProcess"
    value     = "https"
  }

  setting {
    namespace = "aws:elbv2:listener:443"
    name      = "ListenerEnabled"
    value     = "true"
  }

  setting {
    namespace = "aws:elbv2:listener:443"
    name      = "Protocol"
    value     = "HTTPS"
  }

  setting {
    namespace = "aws:elbv2:listener:443"
    name      = "SSLCertificateArns"
    value     = var.m_certificate_arn
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "Port"
    value     = "443"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "Protocol"
    value     = "HTTPS"
  }

  setting {
    name      = "DeleteOnTerminate"
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    value     = var.m_delete_on_terminate
  }

  setting {
    namespace = "aws:elasticbeanstalk:managedactions"
    name      = "PreferredStartTime"
    value     = var.m_preferred_start_time
  }

  setting {
    namespace = "aws:elasticbeanstalk:managedactions:platformupdate"
    name      = "UpdateLevel"
    value     = var.m_update_level
  }

  #=====================================LOGGING======================================#

  setting {
    namespace = "aws:elasticbeanstalk:hostmanager"
    name      = "LogPublicationControl"
    value     = var.m_enable_log_publication_control
  }

  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    name      = "StreamLogs"
    value     = var.m_enable_stream_logs
  }

  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    name      = "RetentionInDays"
    value     = var.m_logs_retention_in_days
  }

  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs:health"
    name      = "HealthStreamingEnabled"
    value     = var.m_health_streaming_enabled
  }

  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs:health"
    name      = "DeleteOnTerminate"
    value     = var.m_health_streaming_delete_on_terminate
  }

  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs:health"
    name      = "RetentionInDays"
    value     = var.m_health_streaming_retention_in_days
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "DisableIMDSv1"
    value     = "true"
  }
  setting {
    namespace = "aws:ec2:instances"
    name      = "SupportedArchitectures"
    value     = var.m_ec2_supported_architectures
  }
}

module "beanstalk_role" {
  source             = "git@github.com:TotalEnergies/aws-iac-module-iam.git?ref=v1.2.0"
  m_app_name         = var.m_app_name
  m_environment_tag  = var.m_environment_tag
  m_iam_role_label   = "eb-${var.m_resource_name}"
  m_role_description = "IAM Role for Beanstalk"
  m_trusted_role_services = [
    "elasticbeanstalk.amazonaws.com"
  ]
  m_custom_role_policy_arns = []
  m_tags                    = merge(var.m_tags, { Name = "${local.app_label}-iam-role" })
}

data "aws_iam_policy" "customer_policy" {
  arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkManagedUpdatesCustomerRolePolicy"
}

resource "aws_iam_role_policy_attachment" "customer_policy_beanstalk" {
  role       = module.beanstalk_role.iam_role_name
  policy_arn = data.aws_iam_policy.customer_policy.arn
}

data "aws_iam_policy" "health_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkEnhancedHealth"
}

resource "aws_iam_role_policy_attachment" "health_policy_beanstalk" {
  role       = module.beanstalk_role.iam_role_name
  policy_arn = data.aws_iam_policy.health_policy.arn
}

data "aws_iam_policy" "eb_core_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkRoleCore"
}

resource "aws_iam_role_policy_attachment" "eb_core_policy_beanstalk" {
  role       = module.beanstalk_role.iam_role_name
  policy_arn = data.aws_iam_policy.eb_core_policy.arn
}

data "aws_iam_policy" "cwl_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkRoleCWL"
}

resource "aws_iam_role_policy_attachment" "cwl_policy_beanstalk" {
  role       = module.beanstalk_role.iam_role_name
  policy_arn = data.aws_iam_policy.cwl_policy.arn
}

module "ec2_role" {
  source                     = "git@github.com:TotalEnergies/aws-iac-module-iam.git?ref=v1.2.0"
  m_app_name                 = var.m_app_name
  m_environment_tag          = var.m_environment_tag
  m_iam_role_label           = "ec2-${var.m_resource_name}"
  m_role_description         = "IAM Role for ec2"
  m_trusted_role_services    = ["ec2.amazonaws.com"]
  m_instance_profile_enabled = true
  m_custom_role_policy_arns  = []
  m_tags                     = merge(var.m_tags, { Name = "${local.app_label}-iam-role" })
}

data "aws_iam_policy" "web_policy" {
  arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
}

resource "aws_iam_role_policy_attachment" "web_policy_beanstalk" {
  role       = module.ec2_role.iam_role_name
  policy_arn = data.aws_iam_policy.web_policy.arn
}

data "aws_iam_policy" "multi_container_policy" {
  arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkMulticontainerDocker"
}

resource "aws_iam_role_policy_attachment" "multi_container_policy_beanstalk" {
  role       = module.ec2_role.iam_role_name
  policy_arn = data.aws_iam_policy.multi_container_policy.arn
}

data "aws_iam_policy" "worker_policy" {
  arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWorkerTier"
}

resource "aws_iam_role_policy_attachment" "worker_policy_beanstalk" {
  role       = module.ec2_role.iam_role_name
  policy_arn = data.aws_iam_policy.worker_policy.arn
}

data "aws_iam_policy" "ssm_policy" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ssm_policy_beanstalk" {
  role       = module.ec2_role.iam_role_name
  policy_arn = data.aws_iam_policy.ssm_policy.arn
}

data "aws_iam_policy" "cw_policy" {
  arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "cw_policy_beanstalk" {
  role       = module.ec2_role.iam_role_name
  policy_arn = data.aws_iam_policy.cw_policy.arn
}

data "aws_iam_policy" "ecr_policy" {
  arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "ecr_policy_beanstalk" {
  role       = module.ec2_role.iam_role_name
  policy_arn = data.aws_iam_policy.ecr_policy.arn
}