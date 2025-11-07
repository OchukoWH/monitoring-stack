output "instance_public_ips" {
  description = "Public IP addresses of all monitoring instances"
  value       = aws_instance.monitoring_nodes[*].public_ip
}

output "instance_private_ips" {
  description = "Private IP addresses of all monitoring instances"
  value       = aws_instance.monitoring_nodes[*].private_ip
}

output "ssh_commands" {
  description = "SSH commands to connect to each instance"
  value = {
    prometheus = "ssh -i monitoring-key ubuntu@${aws_instance.monitoring_nodes[0].public_ip}"
    grafana    = "ssh -i monitoring-key ubuntu@${aws_instance.monitoring_nodes[1].public_ip}"
    loki       = "ssh -i monitoring-key ubuntu@${aws_instance.monitoring_nodes[2].public_ip}"
    promtail   = "ssh -i monitoring-key ubuntu@${aws_instance.monitoring_nodes[3].public_ip}"
  }
}

output "grafana_url" {
  description = "Grafana web interface URL"
  value       = "http://${aws_instance.monitoring_nodes[1].public_ip}:3000"
}

output "prometheus_url" {
  description = "Prometheus web interface URL"
  value       = "http://${aws_instance.monitoring_nodes[0].public_ip}:9090"
}

output "stack_name" {
  description = "Monitoring stack name"
  value       = var.stack_name
}

output "aws_region" {
  description = "AWS region"
  value       = var.aws_region
}
