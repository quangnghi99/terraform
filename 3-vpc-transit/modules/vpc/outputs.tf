output "public_ip" {
  value = aws_eip.nat_gw_eip.public_ip
}