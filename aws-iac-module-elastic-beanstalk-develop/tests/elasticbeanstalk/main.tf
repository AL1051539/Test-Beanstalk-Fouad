data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

data "aws_vpc" "self" {
  tags = {
    Name = format("vpc-alzp-%s", local.aws_region)
  }
}

data "aws_route_table" "private" {
  vpc_id = local.vpc_id
  tags = {
    Name = format("rtb-alzp-%s", local.aws_region)
  }
}

locals {
  vpc_id         = data.aws_vpc.self.id
  aws_region     = data.aws_region.current.name
  route_table_id = data.aws_route_table.private.id

  g_app_name                  = "test"
  g_environment_tag           = "d"
  m_ec2_instance_type         = "t2.micro"
  g_cidr_block_zone_c         = "10.234.161.32/27"
  g_cidr_block_zone_a         = "10.234.161.64/27"
  m_domain_name               = "piloteaicd.private.alzp.tgscloud.net"
  m_cname_prefix              = "mig-test"
  m_subject_alternative_names = []
  m_bucket_name               = "beanstalk-app"
  m_ec2_root_volume_size      = "10"
  m_env_solution_stack_name   = "64bit Amazon Linux 2 v3.2.10 running Corretto 11"

  common_tags = {
    Owner = "SDA"
  }
}

# ███╗   ██╗███████╗████████╗██╗    ██╗ ██████╗ ██████╗ ██╗  ██╗
# ████╗  ██║██╔════╝╚══██╔══╝██║    ██║██╔═══██╗██╔══██╗██║ ██╔╝
# ██╔██╗ ██║█████╗     ██║   ██║ █╗ ██║██║   ██║██████╔╝█████╔╝
# ██║╚██╗██║██╔══╝     ██║   ██║███╗██║██║   ██║██╔══██╗██╔═██╗
# ██║ ╚████║███████╗   ██║   ╚███╔███╔╝╚██████╔╝██║  ██║██║  ██╗
# ╚═╝  ╚═══╝╚══════╝   ╚═╝    ╚══╝╚══╝  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝

module "subnet_a" {
  source = "git@github.com:TotalEnergies/aws-iac-module-subnet.git?ref=v1.0.0"

  m_app_name        = local.g_app_name
  m_environment_tag = local.g_environment_tag
  m_tags            = local.common_tags

  m_vpc_id                  = data.aws_vpc.self.id
  m_cidr_block              = local.g_cidr_block_zone_a
  m_availability_zone       = "${local.aws_region}a"
  m_subnet_label            = format("snet-alzp-%s", local.aws_region)
  m_map_public_ip_on_launch = false
}

module "subnet_c" {
  source = "git@github.com:TotalEnergies/aws-iac-module-subnet.git?ref=v1.0.0"

  m_app_name        = local.g_app_name
  m_environment_tag = local.g_environment_tag
  m_tags            = local.common_tags

  m_vpc_id                  = local.vpc_id
  m_cidr_block              = local.g_cidr_block_zone_c
  m_availability_zone       = "${local.aws_region}c"
  m_subnet_label            = format("snet-alzp-%s", local.aws_region)
  m_map_public_ip_on_launch = false
}

#███████╗███████╗ ██████╗██╗   ██╗██████╗ ██╗████████╗██╗   ██╗     ██████╗ ██████╗  ██████╗ ██╗   ██╗██████╗
#██╔════╝██╔════╝██╔════╝██║   ██║██╔══██╗██║╚══██╔══╝╚██╗ ██╔╝    ██╔════╝ ██╔══██╗██╔═══██╗██║   ██║██╔══██╗
#███████╗█████╗  ██║     ██║   ██║██████╔╝██║   ██║    ╚████╔╝     ██║  ███╗██████╔╝██║   ██║██║   ██║██████╔╝
#╚════██║██╔══╝  ██║     ██║   ██║██╔══██╗██║   ██║     ╚██╔╝      ██║   ██║██╔══██╗██║   ██║██║   ██║██╔═══╝
#███████║███████╗╚██████╗╚██████╔╝██║  ██║██║   ██║      ██║       ╚██████╔╝██║  ██║╚██████╔╝╚██████╔╝██║
#╚══════╝╚══════╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝   ╚═╝      ╚═╝        ╚═════╝ ╚═╝  ╚═╝ ╚═════╝  ╚═════╝ ╚═╝

module "alb_sg" {
  source = "git@github.com:TotalEnergies/aws-iac-module-security-group.git?ref=v1.1.2"

  m_app_name        = local.g_app_name
  m_environment_tag = local.g_environment_tag
  m_tags            = local.common_tags

  m_vpc_id        = local.vpc_id
  m_resource_name = "loadbalancer"

  m_ingress_rules = [
    {
      from_port   = "443"
      to_port     = "443"
      protocol    = "tcp"
      cidr_blocks = [local.g_cidr_block_zone_a, local.g_cidr_block_zone_c]

    }
  ]
}

module "app_sg" {
  source = "git@github.com:TotalEnergies/aws-iac-module-security-group.git?ref=v1.1.2"

  depends_on = [
    module.alb_sg,
  ]

  m_app_name        = local.g_app_name
  m_environment_tag = local.g_environment_tag
  m_tags            = local.common_tags

  m_vpc_id        = local.vpc_id
  m_resource_name = "beanstalk"

  m_ingress_rules = [
    {
      from_port       = "443"
      to_port         = "443"
      protocol        = "tcp"
      security_groups = [module.alb_sg.securitygroup_id]
    }
  ]
}

module "ep_ssm_sg" {

  source = "git@github.com:TotalEnergies/aws-iac-module-security-group.git?ref=v1.1.2"

  m_app_name        = local.g_app_name
  m_environment_tag = local.g_environment_tag
  m_tags            = local.common_tags

  m_vpc_id        = local.vpc_id
  m_resource_name = "ep_ssm"
  m_ingress_rules = [
    {
      from_port       = "443"
      to_port         = "443"
      protocol        = "tcp"
      cidr_blocks     = []
      security_groups = [module.app_sg.securitygroup_id]
    }
  ]
}

module "ep_cloudformation_sg" {

  source = "git@github.com:TotalEnergies/aws-iac-module-security-group.git?ref=v1.1.2"

  m_app_name        = local.g_app_name
  m_environment_tag = local.g_environment_tag
  m_tags            = local.common_tags

  m_vpc_id        = local.vpc_id
  m_resource_name = "ep_cloudformation"
  m_ingress_rules = [
    {
      from_port       = "443"
      to_port         = "443"
      protocol        = "tcp"
      cidr_blocks     = []
      security_groups = [module.app_sg.securitygroup_id]
    }
  ]
}

module "ep_sqs_sg" {

  source = "git@github.com:TotalEnergies/aws-iac-module-security-group.git?ref=v1.1.2"

  m_app_name        = local.g_app_name
  m_environment_tag = local.g_environment_tag
  m_tags            = local.common_tags

  m_vpc_id        = local.vpc_id
  m_resource_name = "ep_sqs"
  m_ingress_rules = [
    {
      from_port       = "443"
      to_port         = "443"
      protocol        = "tcp"
      cidr_blocks     = []
      security_groups = [module.app_sg.securitygroup_id]
    }
  ]
}

module "ep_beanstalk_sg" {

  source = "git@github.com:TotalEnergies/aws-iac-module-security-group.git?ref=v1.1.2"

  m_app_name        = local.g_app_name
  m_environment_tag = local.g_environment_tag
  m_tags            = local.common_tags

  m_vpc_id        = local.vpc_id
  m_resource_name = "ep_beanstalk"
  m_ingress_rules = [
    {
      from_port       = "443"
      to_port         = "443"
      protocol        = "tcp"
      cidr_blocks     = []
      security_groups = [module.app_sg.securitygroup_id]
    }
  ]
}

module "ep_logs_sg" {

  source = "git@github.com:TotalEnergies/aws-iac-module-security-group.git?ref=v1.1.2"

  m_app_name        = local.g_app_name
  m_environment_tag = local.g_environment_tag
  m_tags            = local.common_tags

  m_vpc_id        = local.vpc_id
  m_resource_name = "ep_logs"
  m_ingress_rules = [
    {
      from_port       = "443"
      to_port         = "443"
      protocol        = "tcp"
      cidr_blocks     = []
      security_groups = [module.app_sg.securitygroup_id, module.alb_sg.securitygroup_id]
    }
  ]
}

#██╗   ██╗██████╗  ██████╗    ███████╗███╗   ██╗██████╗ ██████╗  ██████╗ ██╗███╗   ██╗████████╗███████╗
#██║   ██║██╔══██╗██╔════╝    ██╔════╝████╗  ██║██╔══██╗██╔══██╗██╔═══██╗██║████╗  ██║╚══██╔══╝██╔════╝
#██║   ██║██████╔╝██║         █████╗  ██╔██╗ ██║██║  ██║██████╔╝██║   ██║██║██╔██╗ ██║   ██║   ███████╗
#╚██╗ ██╔╝██╔═══╝ ██║         ██╔══╝  ██║╚██╗██║██║  ██║██╔═══╝ ██║   ██║██║██║╚██╗██║   ██║   ╚════██║
# ╚████╔╝ ██║     ╚██████╗    ███████╗██║ ╚████║██████╔╝██║     ╚██████╔╝██║██║ ╚████║   ██║   ███████║
#  ╚═══╝  ╚═╝      ╚═════╝    ╚══════╝╚═╝  ╚═══╝╚═════╝ ╚═╝      ╚═════╝ ╚═╝╚═╝  ╚═══╝   ╚═╝   ╚══════╝

module "vpc_gtwep_s3" {

  source = "git@github.com:TotalEnergies/aws-iac-module-vpc-endpoint.git?ref=v1.0.0"

  m_app_name        = local.g_app_name
  m_environment_tag = local.g_environment_tag
  m_tags            = local.common_tags

  m_vpc_endpoint_type = "Gateway"

  m_vpc_id = local.vpc_id

  m_endpoint_label = "s3"
  m_service_name   = "com.amazonaws.${local.aws_region}.s3"
}

resource "aws_vpc_endpoint_route_table_association" "private_s3" {
  depends_on = [
    module.vpc_gtwep_s3
  ]
  route_table_id  = local.route_table_id
  vpc_endpoint_id = module.vpc_gtwep_s3.vpcendpoint_id
}

module "vpc_itfep_ebs" {

  source = "git@github.com:TotalEnergies/aws-iac-module-vpc-endpoint.git?ref=v1.0.0"


  depends_on = [
    module.subnet_a,
    module.subnet_c,
    module.ep_beanstalk_sg
  ]

  m_app_name        = local.g_app_name
  m_environment_tag = local.g_environment_tag
  m_tags            = local.common_tags

  m_vpc_endpoint_type   = "Interface"
  m_private_dns_enabled = true

  m_vpc_id             = local.vpc_id
  m_subnet_ids         = [module.subnet_a.subnet_id, module.subnet_c.subnet_id]
  m_security_group_ids = [module.ep_beanstalk_sg.securitygroup_id]

  m_endpoint_label = "elasticbeanstalk"
  m_service_name   = "com.amazonaws.${local.aws_region}.elasticbeanstalk"
}

module "vpc_itfep_ebshealth" {

  source = "git@github.com:TotalEnergies/aws-iac-module-vpc-endpoint.git?ref=v1.0.0"

  depends_on = [
    module.subnet_a,
    module.subnet_c,
    module.ep_beanstalk_sg
  ]

  m_app_name        = local.g_app_name
  m_environment_tag = local.g_environment_tag
  m_tags            = local.common_tags

  m_vpc_endpoint_type   = "Interface"
  m_private_dns_enabled = true

  m_vpc_id             = local.vpc_id
  m_subnet_ids         = [module.subnet_a.subnet_id, module.subnet_c.subnet_id]
  m_security_group_ids = [module.ep_beanstalk_sg.securitygroup_id]

  m_endpoint_label = "elasticbeanstalk-health"
  m_service_name   = "com.amazonaws.${local.aws_region}.elasticbeanstalk-health"

}

module "vpc_itfep_ec2messages" {

  source = "git@github.com:TotalEnergies/aws-iac-module-vpc-endpoint.git?ref=v1.0.0"

  depends_on = [
    module.subnet_a,
    module.subnet_c,
    module.ep_ssm_sg
  ]

  m_app_name        = local.g_app_name
  m_environment_tag = local.g_environment_tag
  m_tags            = local.common_tags

  m_vpc_endpoint_type = "Interface"

  m_vpc_id             = local.vpc_id
  m_subnet_ids         = [module.subnet_a.subnet_id, module.subnet_c.subnet_id]
  m_security_group_ids = [module.ep_ssm_sg.securitygroup_id]

  m_endpoint_label      = "ec2messages"
  m_service_name        = "com.amazonaws.${local.aws_region}.ec2messages"
  m_private_dns_enabled = true
}

module "vpc_itfep_ssm" {

  source = "git@github.com:TotalEnergies/aws-iac-module-vpc-endpoint.git?ref=v1.0.0"

  depends_on = [
    module.subnet_a,
    module.subnet_c,
    module.ep_ssm_sg
  ]

  m_app_name        = local.g_app_name
  m_environment_tag = local.g_environment_tag
  m_tags            = local.common_tags

  m_vpc_endpoint_type = "Interface"

  m_vpc_id             = local.vpc_id
  m_subnet_ids         = [module.subnet_a.subnet_id, module.subnet_c.subnet_id]
  m_security_group_ids = [module.ep_ssm_sg.securitygroup_id]

  m_endpoint_label      = "ssm"
  m_service_name        = "com.amazonaws.${local.aws_region}.ssm"
  m_private_dns_enabled = true
}

module "vpc_itfep_ssmmessages" {

  source = "git@github.com:TotalEnergies/aws-iac-module-vpc-endpoint.git?ref=v1.0.0"

  depends_on = [
    module.subnet_a,
    module.subnet_c,
    module.ep_ssm_sg
  ]

  m_app_name        = local.g_app_name
  m_environment_tag = local.g_environment_tag
  m_tags            = local.common_tags

  m_vpc_endpoint_type = "Interface"

  m_vpc_id             = local.vpc_id
  m_subnet_ids         = [module.subnet_a.subnet_id, module.subnet_c.subnet_id]
  m_security_group_ids = [module.ep_ssm_sg.securitygroup_id]

  m_endpoint_label      = "ssmmessages"
  m_service_name        = "com.amazonaws.${local.aws_region}.ssmmessages"
  m_private_dns_enabled = true
}

module "vpc_itfep_sqs" {

  source = "git@github.com:TotalEnergies/aws-iac-module-vpc-endpoint.git?ref=v1.0.0"

  depends_on = [
    module.subnet_a,
    module.subnet_c,
    module.ep_sqs_sg
  ]

  m_app_name        = local.g_app_name
  m_environment_tag = local.g_environment_tag
  m_tags            = local.common_tags

  m_vpc_endpoint_type = "Interface"

  m_vpc_id             = local.vpc_id
  m_subnet_ids         = [module.subnet_a.subnet_id, module.subnet_c.subnet_id]
  m_security_group_ids = [module.ep_sqs_sg.securitygroup_id]

  m_endpoint_label      = "sqs"
  m_service_name        = "com.amazonaws.${local.aws_region}.sqs"
  m_private_dns_enabled = true
}

module "vpc_itfep_cloudformation" {

  source = "git@github.com:TotalEnergies/aws-iac-module-vpc-endpoint.git?ref=v1.0.0"

  depends_on = [
    module.subnet_a,
    module.subnet_c,
    module.ep_cloudformation_sg
  ]

  m_app_name        = local.g_app_name
  m_environment_tag = local.g_environment_tag
  m_tags            = local.common_tags

  m_vpc_endpoint_type   = "Interface"
  m_private_dns_enabled = true

  m_vpc_id             = local.vpc_id
  m_subnet_ids         = [module.subnet_a.subnet_id, module.subnet_c.subnet_id]
  m_security_group_ids = [module.ep_cloudformation_sg.securitygroup_id]

  m_endpoint_label = "cloudformation"
  m_service_name   = "com.amazonaws.${local.aws_region}.cloudformation"
}

module "vpc_itfep_cwlogs" {

  source = "git@github.com:TotalEnergies/aws-iac-module-vpc-endpoint.git?ref=v1.0.0"

  depends_on = [
    module.subnet_a,
    module.subnet_c,
    module.ep_logs_sg
  ]

  m_app_name        = local.g_app_name
  m_environment_tag = local.g_environment_tag
  m_tags            = local.common_tags

  m_vpc_endpoint_type   = "Interface"
  m_private_dns_enabled = true

  m_vpc_id             = local.vpc_id
  m_subnet_ids         = [module.subnet_a.subnet_id, module.subnet_c.subnet_id]
  m_security_group_ids = [module.ep_logs_sg.securitygroup_id]

  m_endpoint_label = "cloudwatchlogs"
  m_service_name   = "com.amazonaws.${local.aws_region}.logs"
}

# ██╗      ██████╗  █████╗ ██████╗     ██████╗  █████╗ ██╗     ███████╗███╗   ██╗ ██████╗███████╗██████╗
# ██║     ██╔═══██╗██╔══██╗██╔══██╗    ██╔══██╗██╔══██╗██║     ██╔════╝████╗  ██║██╔════╝██╔════╝██╔══██╗
# ██║     ██║   ██║███████║██║  ██║    ██████╔╝███████║██║     █████╗  ██╔██╗ ██║██║     █████╗  ██████╔╝
# ██║     ██║   ██║██╔══██║██║  ██║    ██╔══██╗██╔══██║██║     ██╔══╝  ██║╚██╗██║██║     ██╔══╝  ██╔══██╗
# ███████╗╚██████╔╝██║  ██║██████╔╝    ██████╔╝██║  ██║███████╗███████╗██║ ╚████║╚██████╗███████╗██║  ██║
# ╚══════╝ ╚═════╝ ╚═╝  ╚═╝╚═════╝     ╚═════╝ ╚═╝  ╚═╝╚══════╝╚══════╝╚═╝  ╚═══╝ ╚═════╝╚══════╝╚═╝  ╚═╝

module "cm" {

  source = "git@github.com:TotalEnergies/aws-iac-module-certificate-manager.git?ref=v1.0.0"

  m_app_name        = local.g_app_name
  m_environment_tag = local.g_environment_tag
  m_tags            = local.common_tags
  m_resource_name   = "certificate"

  m_wait_for_validation       = true
  m_domain_name               = local.m_domain_name
  m_subject_alternative_names = local.m_subject_alternative_names

  m_route53_validation_enable = false
  m_validation_method         = "DNS"

  m_certificate_transparency_logging_preference = true
}

module "alb" {

  source = "git@github.com:TotalEnergies/aws-iac-module-load-balancer.git?ref=v1.0.1"

  depends_on = [
    module.subnet_a,
    module.subnet_c,
    module.alb_sg,
    module.cm
  ]

  m_app_name        = local.g_app_name
  m_environment_tag = local.g_environment_tag
  m_tags            = local.common_tags

  m_vpc_id              = local.vpc_id
  m_vpc_subnets         = [module.subnet_a.subnet_id, module.subnet_c.subnet_id]
  m_vpc_security_groups = [module.alb_sg.securitygroup_id]

  m_alb_internal = true

  m_listeners_https = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = "${module.cm.acm_certificate_arn}"
      target_group_index = 0
      action_type        = "forward"
    }
  ]
  m_target_groups = [{
    name                 = "aswd-alb-tg-tevcmanager"
    backend_protocol     = "HTTPS"
    backend_port         = 443
    target_type          = "instance"
    deregistration_delay = 10
    health_check = {
      enabled             = true
      interval            = 30
      path                = "/"
      healthy_threshold   = 3
      unhealthy_threshold = 3
      timeout             = 6
      protocol            = "HTTPS"
      matcher             = "200-399"
    }
  }]
}

# ██████╗  █████╗ ████████╗ █████╗ ███████╗████████╗ ██████╗ ██████╗ ███████╗
# ██╔══██╗██╔══██╗╚══██╔══╝██╔══██╗██╔════╝╚══██╔══╝██╔═══██╗██╔══██╗██╔════╝
# ██║  ██║███████║   ██║   ███████║███████╗   ██║   ██║   ██║██████╔╝█████╗
# ██║  ██║██╔══██║   ██║   ██╔══██║╚════██║   ██║   ██║   ██║██╔══██╗██╔══╝
# ██████╔╝██║  ██║   ██║   ██║  ██║███████║   ██║   ╚██████╔╝██║  ██║███████╗
# ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚══════╝

module "log_bucket" {

  source = "git@github.com:TotalEnergies/aws-iac-module-log-bucket.git?ref=v2.0.4"

  m_app_name        = local.g_app_name
  m_environment_tag = local.g_environment_tag
  m_tags            = local.common_tags
}

module "s3_ebs" {

  source = "git@github.com:TotalEnergies/aws-iac-module-s3.git?ref=v2.0.3"

  depends_on = [
    module.log_bucket
  ]

  m_app_name        = local.g_app_name
  m_environment_tag = local.g_environment_tag
  m_tags            = local.common_tags

  m_bucket_name       = local.m_bucket_name
  m_log_bucket_id     = module.log_bucket.log_bucket_id
  m_enable_versioning = false

  m_acl = "private"
}

resource "aws_s3_bucket_object" "sample_app" {
  #ts:skip=AC_AWS_0498
  depends_on = [
    module.s3_ebs
  ]

  bucket                 = module.s3_ebs.sto_bucket_id
  key                    = "correto-custom-2.0.zip"
  source                 = "sample-app/correto-custom-2.0.zip"
  etag                   = filemd5("sample-app/correto-custom-2.0.zip")
  acl                    = "private"
  server_side_encryption = "AES256"
}

# █████╗ ██████╗ ██████╗ ██╗     ██╗ ██████╗ █████╗ ████████╗██╗ ██████╗ ███╗   ██╗
#██╔══██╗██╔══██╗██╔══██╗██║     ██║██╔════╝██╔══██╗╚══██╔══╝██║██╔═══██╗████╗  ██║
#███████║██████╔╝██████╔╝██║     ██║██║     ███████║   ██║   ██║██║   ██║██╔██╗ ██║
#██╔══██║██╔═══╝ ██╔═══╝ ██║     ██║██║     ██╔══██║   ██║   ██║██║   ██║██║╚██╗██║
#██║  ██║██║     ██║     ███████╗██║╚██████╗██║  ██║   ██║   ██║╚██████╔╝██║ ╚████║
#╚═╝  ╚═╝╚═╝     ╚═╝     ╚══════╝╚═╝ ╚═════╝╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝

module "beanstalk" {

  source = "../..//"

  depends_on = [
    module.subnet_a,
    module.subnet_c,
    module.app_sg,
    module.cm,
    module.alb,
    module.s3_ebs
  ]

  m_app_name        = local.g_app_name
  m_environment_tag = local.g_environment_tag
  m_tags            = merge(local.common_tags, { "map-migrated" = "MPE-19821" })
  m_resource_name   = "tevcmanager-beanstalk"

  m_vpc_id                 = local.vpc_id
  m_subnet_ids             = [module.subnet_a.subnet_id, module.subnet_c.subnet_id]
  m_vpc_security_group_ids = [module.app_sg.securitygroup_id]
  m_alb_security_group_ids = [module.alb_sg.securitygroup_id]

  m_certificate_arn = module.cm.acm_certificate_arn

  m_bucket     = module.s3_ebs.sto_bucket_id
  m_object_key = aws_s3_bucket_object.sample_app.id

  m_ec2_instance_type           = local.m_ec2_instance_type
  m_ec2_root_volume_size        = local.m_ec2_root_volume_size
  m_env_solution_stack_name     = local.m_env_solution_stack_name
  m_associate_public_ip_address = false

  m_cname_prefix       = local.m_cname_prefix
  m_application_domain = local.m_domain_name

  m_tier                   = "WebServer"
  m_wait_for_ready_timeout = "10m"
  m_environment_variables  = []

  m_enhanced_reporting_enabled = true
  m_managed_actions_enabled    = true
  m_preferred_start_time       = "Sun:10:00"
  m_update_level               = "minor"

  m_availability_zone_selector = "Any 2"
  m_scheme                     = "internal"
  m_elb_arn                    = module.alb.lb_arn
  m_environment_type           = "LoadBalanced"
  m_autoscale_min              = 2
  m_autoscale_max              = 2

  m_rolling_update_enabled  = true
  m_rolling_update_type     = "Health"
  m_updating_min_in_service = 1
  m_updating_max_batch      = 2

  m_delete_on_terminate = false

  m_logs_retention_in_days = 90

  m_enable_log_publication_control = false

  m_enable_stream_logs       = true
  m_health_streaming_enabled = true

  m_health_streaming_delete_on_terminate = false
  m_health_streaming_retention_in_days   = 7

  m_prefer_legacy_service_policy = false

  m_role_arn = [
    "elasticbeanstalk.amazonaws.com",
    "ec2.amazonaws.com",
    "autoscaling.amazonaws.com",
    "elasticloadbalancing.amazonaws.com",
    "ecs.amazonaws.com",
    "cloudformation.amazonaws.com"
  ]
  m_access_level_actions = [
    "cloudwatch:PutMetricData",
    "ec2:DescribeInstanceStatus",
    "ssm:*",
    "ec2messages:*",
    "s3:*",
    "sqs:*",
    "elasticbeanstalk:*"
  ]
  m_managed_policy_arns = [
    "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier",
    "arn:aws:iam::aws:policy/AWSElasticBeanstalkMulticontainerDocker",
    "arn:aws:iam::aws:policy/AWSElasticBeanstalkWorkerTier",
    "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilderECRContainerBuilds",
    "arn:aws:iam::aws:policy/AWSElasticBeanstalkManagedUpdatesCustomerRolePolicy",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]
}

