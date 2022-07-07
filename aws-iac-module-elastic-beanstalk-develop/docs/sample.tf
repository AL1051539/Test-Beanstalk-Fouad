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
