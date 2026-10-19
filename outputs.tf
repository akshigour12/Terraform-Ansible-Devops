output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}


output "ssh_private_key_file" {
  description = "Generated SSH private key"
  value       = local_sensitive_file.ansible_private_key.filename
}


output "control_instance_id" {
  value = module.control.instance_id
}

output "control_public_ip" {
  value = module.control.public_ip
}

output "control_private_ip" {
  value = module.control.private_ip
}

output "control_public_dns" {
  value = module.control.public_dns
}


output "worker_ubuntu_instance_id" {
  value = module.worker_ubuntu.instance_id
}

output "worker_ubuntu_public_ip" {
  value = module.worker_ubuntu.public_ip
}

output "worker_ubuntu_private_ip" {
  value = module.worker_ubuntu.private_ip
}


output "worker_amazonlinux_instance_id" {
  value = module.worker_amazonlinux.instance_id
}

output "worker_amazonlinux_public_ip" {
  value = module.worker_amazonlinux.public_ip
}

output "worker_amazonlinux_private_ip" {
  value = module.worker_amazonlinux.private_ip
}


output "worker_debian_instance_id" {
  value = module.worker_debian.instance_id
}

output "worker_debian_public_ip" {
  value = module.worker_debian.public_ip
}

output "worker_debian_private_ip" {
  value = module.worker_debian.private_ip
}