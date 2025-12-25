resource "aws_vpc" "primary_vpc" {
  provider = aws.primary
  cidr_block       = var.primary_cidr_block
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = "Primary-vpc-${var.primary_region}"
    Purpose     = "VPC-Peering-Demo"
  }
}
resource "aws_vpc" "secondary_vpc" {
  provider = aws.secondary
  cidr_block       = var.secondary_cidr_block
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = "secondary-vpc-${var.secondary_region}"
    Purpose     = "VPC-Peering-Demo"
  }
}
resource "aws_subnet" "primary_subnet" {
  provider = aws.primary
  vpc_id     = aws_vpc.primary_vpc.id
  cidr_block = var.primary_subnet_cidr_block
  availability_zone = data.aws_availability_zones.primary.names[0]
  map_public_ip_on_launch = true
  tags = {
    Name = "primary-subnet-${var.primary_region}"
  }
}
resource "aws_subnet" "secondary_subnet" {
  provider = aws.secondary
  vpc_id     = aws_vpc.secondary_vpc.id
  cidr_block = var.secondry_subnet_cidr_block
  availability_zone = data.aws_availability_zones.secondary.names[0]
  map_public_ip_on_launch = true
  tags = {
    Name = "secondary-subnet-${var.secondary_region}"
  }
}

resource "aws_internet_gateway" "primary_igw" {
  provider = aws.primary
  vpc_id = aws_vpc.primary_vpc.id

  tags = {
    Name = "primary-IGW-${var.primary_region}"
  }
}
resource "aws_internet_gateway" "secondary_igw" {
  provider = aws.secondary
  vpc_id = aws_vpc.secondary_vpc.id

  tags = {
    Name = "secondary-IGW-${var.secondary_region}"
  }
}
resource "aws_route_table" "primary_rt" {
  provider  = aws.primary
  vpc_id = aws_vpc.primary_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.primary_igw.id
  }

    tags = {
    Name = "primary-rt-${var.primary_region}"
  }
}
resource "aws_route_table" "secondary_rt" {
  provider  = aws.secondary
  vpc_id = aws_vpc.secondary_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.secondary_igw.id
  }

    tags = {
    Name = "secondary-rt-${var.secondary_region}"
  }
}
resource "aws_route_table_association" "primary_rta" {
  provider = aws.primary
  subnet_id      = aws_subnet.primary_subnet.id
  route_table_id = aws_route_table.primary_rt.id
}
resource "aws_route_table_association" "secondary_rta" {
  provider = aws.secondary
  subnet_id      = aws_subnet.secondary_subnet.id
  route_table_id = aws_route_table.secondary_rt.id
}
resource "aws_vpc_peering_connection" "primary-secondary" {
  provider = aws.primary
  peer_owner_id = data.aws_caller_identity.current.account_id
  vpc_id   = aws_vpc.primary_vpc.id
  peer_vpc_id        = aws_vpc.secondary_vpc.id
  peer_region = var.secondary_region
  auto_accept   = false

  tags = {
    Name = "primary-to-secondary"
    side = "Requester"
  }
}
resource "aws_vpc_peering_connection_accepter" "peer" {
  provider                  = aws.secondary
  vpc_peering_connection_id = aws_vpc_peering_connection.primary-secondary.id
  auto_accept               = true

  tags = {
    Name = "Secondary-peering-acceptor"
    Side = "Accepter"
  }
}
resource "aws_route" "primary_to_secondary" {
  provider = aws.primary
  route_table_id = aws_route_table.primary_rt.id
  destination_cidr_block = var.secondary_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.primary-secondary.id
  depends_on = [ aws_vpc_peering_connection_accepter.peer ]
}

resource "aws_route" "secondary_to_primary" {
  provider = aws.secondary
  route_table_id = aws_route_table.secondary_rt.id
  destination_cidr_block = var.primary_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.primary-secondary.id
  depends_on = [ aws_vpc_peering_connection_accepter.peer ]
}
resource "aws_security_group" "primary_sg" {
  provider    = aws.primary
  name        = "primary-vpc-sg"
  description = "Security group for Primary VPC instance"
  vpc_id      = aws_vpc.primary_vpc.id

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ICMP from Secondary VPC"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.secondary_cidr_block]
  }

  ingress {
    description = "All traffic from Secondary VPC"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.secondary_cidr_block]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "Primary-VPC-SG"
  }
}
resource "aws_security_group" "secondary_sg" {
  provider    = aws.secondary
  name        = "secondary-vpc-sg"
  description = "Security group for Secondary VPC instance"
  vpc_id      = aws_vpc.secondary_vpc.id

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ICMP from Primary VPC"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.primary_cidr_block]
  }

  ingress {
    description = "All traffic from Primary VPC"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.primary_cidr_block]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "Secondary-VPC-SG"
  }
}
resource "aws_instance" "primary_ec2" {
  provider = aws.primary
  ami = data.aws_ami.primary_ami.id
  instance_type = var.instance_type
  subnet_id = aws_subnet.primary_subnet.id
  vpc_security_group_ids = [aws_security_group.primary_sg.id]
  key_name = var.primary_key
  user_data = local.primary_user_data
  tags = {
    Name = "Primary-Ec2-Instance"
    region = var.primary_region
  }
  depends_on = [ aws_vpc_peering_connection_accepter.peer ]
}
resource "aws_instance" "secondary_ec2" {
  provider = aws.secondary
  ami = data.aws_ami.secondary_ami.id
  instance_type = var.instance_type
  subnet_id = aws_subnet.secondary_subnet.id
  vpc_security_group_ids = [aws_security_group.secondary_sg.id]
  key_name = var.secondary_key
  user_data = local.secondary_user_data
  tags = {
    Name = "secondary-Ec2-Instance"
    region = var.secondary_region
  }
  depends_on = [ aws_vpc_peering_connection_accepter.peer ]
}