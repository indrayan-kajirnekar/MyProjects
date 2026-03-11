# Create a VPC
resource "aws_vpc" "myvpc" {
  cidr_block = var.cidr

  tags = {
    Name = "myvpc"
  }
}

# Create First Subnet sub1
resource "aws_subnet" "sub1" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "sub1"
  }
}

# Create Second Subnet sub2
resource "aws_subnet" "sub2" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "sub2"
  }
}

# Create Internet Gateway igw
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "igw"
  }
}

# Create NAT Gateway ngw
# resource "aws_nat_gateway" "ngw" {
#   vpc_id = aws_vpc.myvpc.id

#   tags = {
#     Name = "ngw"
#   }

# }

# Create Route Table RT1
resource "aws_route_table" "RT1" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "RT1"
  }
}

# Create Route Table RT2
# resource "aws_route_table" "RT2" {
#   vpc_id = aws_vpc.myvpc.id

#   route {
#     cidr_block     = "0.0.0.0"
#     nat_gateway_id = aws_nat_gateway.ngw.id
#   }

# }

# Create Route Table subnet associateion for sub1
resource "aws_route_table_association" "RTa1" {
  subnet_id      = aws_subnet.sub1.id
  route_table_id = aws_route_table.RT1.id
}

# Create Route Table subnet associateion for sub2
resource "aws_route_table_association" "RTa2" {
  subnet_id      = aws_subnet.sub2.id
  route_table_id = aws_route_table.RT1.id
}

resource "aws_security_group" "mysg" {
  name   = "mysg"
  vpc_id = aws_vpc.myvpc.id

  ingress {
    description = "App"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "mysg"
  }
}

resource "aws_s3_bucket" "mys3" {
  bucket = "mys3bucketapril2026"

  tags = {
    Name        = "mys3bucketapril2026"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_ownership_controls" "mys3control" {
  bucket = aws_s3_bucket.mys3.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "mys3ab" {
  bucket = aws_s3_bucket.mys3.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "public_read" {
  bucket = aws_s3_bucket.mys3.id
  policy = <<POLICY
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": "*",
        "Action": "s3:GetObject",
        "Resource": "arn:aws:s3:::mys3bucketapril2026/*"
      }
    ]
  }
  POLICY

  depends_on = [aws_s3_bucket_public_access_block.mys3ab]
}

resource "aws_s3_object" "biscuits" {
  bucket       = aws_s3_bucket.mys3.id
  key          = "biscuits.jpg"
  source       = "D:/My Space/Terraform/AWS_TF/biscuits.jpg"
  content_type = "image/jpeg"
}

resource "aws_s3_object" "snacks" {
  bucket       = aws_s3_bucket.mys3.id
  key          = "snacks.jpg"
  source       = "D:/My Space/Terraform/AWS_TF/snacks.jpg"
  content_type = "image/jpeg"
}

resource "aws_s3_object" "powder" {
  bucket       = aws_s3_bucket.mys3.id
  key          = "powder.jpg"
  source       = "D:/My Space/Terraform/AWS_TF/powder.jpg"
  content_type = "image/jpeg"
}

resource "aws_s3_object" "jaggery" {
  bucket       = aws_s3_bucket.mys3.id
  key          = "jaggery.jpg"
  source       = "D:/My Space/Terraform/AWS_TF/jaggery.jpg"
  content_type = "image/jpeg"
}

resource "aws_instance" "myinst1" {
  ami                    = "ami-019715e0d74f695be"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.mysg.id]
  subnet_id              = aws_subnet.sub1.id
  user_data_base64       = base64encode(file("userdata.sh"))

  tags = {
    Name = "myinst1"
  }
}

resource "aws_instance" "myinst2" {
  ami                    = "ami-019715e0d74f695be"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.mysg.id]
  subnet_id              = aws_subnet.sub2.id
  user_data_base64       = base64encode(file("userdata1.sh"))

  tags = {
    Name = "myinst2"
  }
}

# Create applicatio Load Balancer myalb
resource "aws_alb" "myalb" {
  name               = "myalb"
  load_balancer_type = "application"
  internal           = false
  security_groups    = [aws_security_group.mysg.id]
  subnets            = [aws_subnet.sub1.id, aws_subnet.sub2.id]

  tags = {
    Name = "myalb"
  }
}

resource "aws_lb_target_group" "myalbtg" {
  name     = "myalbtg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.myvpc.id

  health_check {
    path = "/"
    port = "traffic-port"
  }
}

resource "aws_lb_target_group_attachment" "myalbtgattach1" {
  target_id        = aws_instance.myinst1.id
  target_group_arn = aws_lb_target_group.myalbtg.arn
  port             = 80
}

resource "aws_lb_target_group_attachment" "myalbtgattach2" {
  target_id        = aws_instance.myinst2.id
  target_group_arn = aws_lb_target_group.myalbtg.arn
  port             = 80
}

resource "aws_lb_listener" "myalblistener" {
  load_balancer_arn = aws_alb.myalb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.myalbtg.arn
    type             = "forward"
  }
}

output "loadbalancerdns" {
  value = aws_alb.myalb.dns_name
}