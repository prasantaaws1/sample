data "aws_availability_zones" "available" {
}

resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "project-vpc"
  }

} 

resource "aws_subnet" "sn1-public" {
  count             = var.az_count
  cidr_block              = "10.0.1.0/24"
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet"
  }
 
}

resource "aws_subnet" "sn2-private" {
  count             = var.az_count
  cidr_block              = "10.0.2.0/24"
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "private-subnet"
  }

}

# resource "aws_eip" "ip" {
#   vpc      = true
  
#   tags = {
#     Name = "elasticIP"
#   }

# }

# resource "aws_nat_gateway" "nat-gateway" {
#   allocation_id = "${aws_eip.ip.id}"
#   subnet_id     = "${aws_subnet.sn1-public.id}"


#   tags = {
#     Name = "nat-gateway"
#   }
# }

resource "aws_security_group" "sg" {
  name   = "sg"
  vpc_id = aws_vpc.vpc.id

  ingress {
    description = "https"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "project-igw"
  }

}

resource "aws_route_table" "rt" {
  count  = var.az_count
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "route" {
  count  = var.az_count
  route_table_id = element(aws_route_table.rt.*.id, count.index)
  //subnet_id      = aws_subnet.sn2-public.id
  subnet_id      = element(aws_subnet.sn2-private.*.id, count.index)
}

