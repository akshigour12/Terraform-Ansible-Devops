output "instance_profile_name" {
  description = "EC2 instance profile"
  value       = aws_iam_instance_profile.ec2.name
}