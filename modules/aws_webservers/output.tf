output "web_eip" {
  value = aws_eip.static_eip.public_ip
}