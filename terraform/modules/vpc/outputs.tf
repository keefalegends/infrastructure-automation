output "vpc_id" {
  value = aws_vpc.lks_vpc.id
}
output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}
output "private_subnet_ids" {
  value = aws_subnet.private-1[*].id
}
output "isolated_subnet_ids" {
  value = aws_subnet.isolated-1[*].id
}
output "private_route_table_id" {
  value = aws_route_table.private-rt.id
}
