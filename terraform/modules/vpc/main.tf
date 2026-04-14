# ── lks-vpc: Application VPC (us-east-1) ───────────────────

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "aws_vpc" "lks_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = { Name = var.vpc_name }
}

resource "aws_internet_gateway" "lks_igw" {
  vpc_id = aws_vpc.lks_vpc.id
  tags   = { Name = "lks-igw" }
}

resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.lks_vpc.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true
  tags = { Name = "lks-public-subnet-${count.index + 1}" }
}

resource "aws_subnet" "public-2" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.lks_vpc.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true
  tags = { Name = "lks-public-subnet-${count.index + 1}" }
}

resource "aws_subnet" "private-1" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.lks_vpc.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]
  tags = { Name = "lks-private-subnet-${count.index + 1}" }
}

resource "aws_subnet" "private-2" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.lks_vpc.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]
  tags = { Name = "lks-private-subnet-${count.index + 1}" }
}

resource "aws_subnet" "isolated-1" {
  count             = length(var.isolated_subnet_cidrs)
  vpc_id            = aws_vpc.lks_vpc.id
  cidr_block        = var.isolated_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]
  tags = { Name = "lks-isolated-subnet-${count.index + 1}" }
}

resource "aws_subnet" "isolated-2" {
  count             = length(var.isolated_subnet_cidrs)
  vpc_id            = aws_vpc.lks_vpc.id
  cidr_block        = var.isolated_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]
  tags = { Name = "lks-isolated-subnet-${count.index + 1}" }
}

resource "aws_eip" "nat" {
  domain = "vpc"
  tags   = { Name = "lks-nat-eip" }
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0]
  tags          = { Name = "lks-nat-gw" }
}

resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.lks_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lks_igw.id
  }
  tags = { Name = "lks-public-rt" }
}

resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.lks_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }
  tags = { Name = "lks-private-rt" }
}

resource "aws_route_table" "isolated-rt" {
  vpc_id = aws_vpc.lks_vpc.id
  tags   = { Name = "lks-isolated-rt" }
}

resource "aws_route_table_association" "public-asoc-1" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_route_table_association" "public-asoc-2" {
  count          = length(aws_subnet.public-2)
  subnet_id      = aws_subnet.public-2[count.index].id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_route_table_association" "private-asoc-1" {
  count          = length(aws_subnet.private-1)
  subnet_id      = aws_subnet.private-1[count.index].id
  route_table_id = aws_route_table.private-rt.id
}

resource "aws_route_table_association" "private-asoc-2" {
  count          = length(aws_subnet.private-2)
  subnet_id      = aws_subnet.private-2[count.index].id
  route_table_id = aws_route_table.private-rt.id
}

resource "aws_route_table_association" "isolated-asoc-1" {
  count          = length(aws_subnet.isolated-1)
  subnet_id      = aws_subnet.isolated-1[count.index].id
  route_table_id = aws_route_table.isolated-rt.id
}

resource "aws_route_table_association" "isolated-asoc-2" {
  count          = length(aws_subnet.isolated-2)
  subnet_id      = aws_subnet.isolated-2[count.index].id
  route_table_id = aws_route_table.isolated-rt.id
}
