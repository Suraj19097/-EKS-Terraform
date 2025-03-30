provider "aws" {
  region = "ap-south-1"
}

resource "aws_vpc" "My_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "My-vpc"
  }
}

resource "aws_subnet" "My_subnet" {
  count = 2
  vpc_id                  = aws_vpc.My_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.My_vpc.cidr_block, 8, count.index)
  availability_zone       = element(["ap-south-1a", "ap-south-1b"], count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "My-subnet-${count.index}"
  }
}

resource "aws_internet_gateway" "My_igw" {
  vpc_id = aws_vpc.My_vpc.id

  tags = {
    Name = "My-igw"
  }
}

resource "aws_route_table" "My_route_table" {
  vpc_id = aws_vpc.My_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.My_igw.id
  }

  tags = {
    Name = "My-route-table"
  }
}

resource "aws_route_table_association" "a" {
  count          = 2
  subnet_id      = aws_subnet.My_subnet[count.index].id
  route_table_id = aws_route_table.My_route_table.id
}

resource "aws_security_group" "My_cluster_sg" {
  vpc_id = aws_vpc.My_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "My-cluster-sg"
  }
}

resource "aws_security_group" "My_node_sg" {
  vpc_id = aws_vpc.My_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "My-node-sg"
  }
}

resource "aws_eks_cluster" "My" {
  name     = "My-cluster"
  role_arn = aws_iam_role.My_cluster_role.arn

  vpc_config {
    subnet_ids         = aws_subnet.My_subnet[*].id
    security_group_ids = [aws_security_group.My_cluster_sg.id]
  }
}

resource "aws_eks_node_group" "My" {
  cluster_name    = aws_eks_cluster.My.name
  node_group_name = "My-node-group"
  node_role_arn   = aws_iam_role.My_node_group_role.arn
  subnet_ids      = aws_subnet.My_subnet[*].id

  scaling_config {
    desired_size = 3
    max_size     = 3
    min_size     = 3
  }

  instance_types = ["t2.medium"]

  remote_access {
    ec2_ssh_key = var.ssh_key_name
    source_security_group_ids = [aws_security_group.My_node_sg.id]
  }
}

resource "aws_iam_role" "My_cluster_role" {
  name = "My-cluster-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "My_cluster_role_policy" {
  role       = aws_iam_role.My_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role" "My_node_group_role" {
  name = "My-node-group-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "My_node_group_role_policy" {
  role       = aws_iam_role.My_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "My_node_group_cni_policy" {
  role       = aws_iam_role.My_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "My_node_group_registry_policy" {
  role       = aws_iam_role.My_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}
