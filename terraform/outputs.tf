output "instance_id" {
  value = module.ec2.instance_id
}

output "document_name" {
  value = module.ssm_orchestration.document_name
}
output "cloudwatch_log_group_name" {
  value = module.honeycomb_cloudwatch_integration.log_group_name
}
