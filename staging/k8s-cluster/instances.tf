# Key Pair
resource "aws_key_pair" "main" {
  key_name   = var.key_pair_name
  public_key = file("${path.module}/../../monitoring-key.pub")

  tags = {
    Name = "${var.stack_name}-keypair"
  }
}

# Monitoring Stack Instances - 4 Ubuntu VMs
resource "aws_instance" "monitoring_nodes" {
  count = 4

  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name              = aws_key_pair.main.key_name
  vpc_security_group_ids = [
    count.index == 0 ? aws_security_group.prometheus.id :
    count.index == 1 ? aws_security_group.grafana.id :
    count.index == 2 ? aws_security_group.loki.id :
    aws_security_group.promtail.id
  ]
  associate_public_ip_address = true

  root_block_device {
    volume_type = "gp3"
    volume_size = 20
    encrypted   = true
  }

  tags = {
    Name = "${var.stack_name}-node-${count.index + 1}"
    Role = count.index == 0 ? "prometheus" : count.index == 1 ? "grafana" : count.index == 2 ? "loki" : "promtail"
  }
}
