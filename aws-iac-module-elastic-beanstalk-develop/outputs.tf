output "elastic_beanstalk_dns_name" {
  description = "The URL to the Load Balancer for this Environment"
  value       = aws_elastic_beanstalk_environment.eb_env.endpoint_url
}

output "elastic_beanstalk_id" {
  description = "ID of the Elastic Beanstalk environment"
  value       = aws_elastic_beanstalk_environment.eb_env.id
}

output "elastic_beanstalk_name" {
  description = "Name of the Elastic Beanstalk environment"
  value       = aws_elastic_beanstalk_environment.eb_env.name
}

output "ec2_instance_role_name" {
  description = "EC2 Instance IAM role name, allow to add other application policies"
  value       = module.ec2_role.iam_role_name
}

output "elastic_beanstalk_application" {
  description = "The Elastic Beanstalk Application specified for this environment"
  value       = aws_elastic_beanstalk_environment.eb_env.application
}

output "elastic_beanstalk_cname" {
  description = "The Elastic Beanstalk CNAME for this environment"
  value       = aws_elastic_beanstalk_environment.eb_env.cname
}

output "elastic_beanstalk_autoscaling_groups" {
  description = "The Elastic Beanstalk autoscaling_groups for this environment"
  value       = aws_elastic_beanstalk_environment.eb_env.autoscaling_groups
}

output "elastic_beanstalk_instances" {
  description = "The Elastic Beanstalk instances for this environment"
  value       = aws_elastic_beanstalk_environment.eb_env.instances
}
