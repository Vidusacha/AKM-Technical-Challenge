output "machine_a_public_ip" {
  value = aws_eip.eip_a.public_ip
}
output "machine_a_private_ip" {
  value = aws_instance.machine_a.private_ip
}
output "machine_b_private_ip" {
  value = aws_instance.machine_b.private_ip
}
output "machine_c_private_ip" {
  value = aws_instance.machine_c.private_ip
}