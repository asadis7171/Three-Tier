
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

# Create a VPC
resource "aws_vpc" "vpc_01" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    Name = "Three-Tier-architecture"
  }
}


# Create Internet Gateway

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.vpc_01.id

    tags = {
       Name =  "Test IGW" 
    }
  
}

#Create Public Subnet 1
resource "aws_subnet" "public-web-subnet-1" {
    vpc_id                  = aws_vpc.vpc_01.id
    cidr_block              = var.public-web-subnet-1-cidr
    availability_zone       = "us-east-1a"
    map_public_ip_on_launch = true

    tags = {
        Name = "Public Subnet 1"
    } 
}


#Create Public Subnet 2
resource "aws_subnet" "public-web-subnet-2" {
    vpc_id                  = aws_vpc.vpc_01.id
    cidr_block              = var.public-web-subnet-2-cidr
    availability_zone       = "us-east-1b"
    map_public_ip_on_launch = true

    tags = {
        Name = "Public Subnet 2"
    } 
}

#Create Route Table

resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.vpc_01.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }



  tags = {
    Name = "Public Route Table"
  }
}

#Route table association

resource "aws_route_table_association" "public-subnet-1-route-table-association" {
    subnet_id       = aws_subnet.public-web-subnet-1.id
    route_table_id  = aws_route_table.public-route-table.id 
  
}

resource "aws_route_table_association" "public-subnet-2-route-table-association" {
    subnet_id       = aws_subnet.public-web-subnet-2.id
    route_table_id  = aws_route_table.public-route-table.id 
  
}

# Create Private Subnet 1 for App Tier

resource "aws_subnet" "private-app-subnet-1" {
    vpc_id                  = aws_vpc.vpc_01.id
    cidr_block              = var.private-app-subnet-1-cidr
    availability_zone       = "us-east-1a"
    map_public_ip_on_launch = false

    tags = {
        Name = "Private Subnet 1 | App Tier"
    } 
}


#Create Private  Subnet 2 for App Tier
resource "aws_subnet" "private-app-subnet-2" {
    vpc_id                  = aws_vpc.vpc_01.id
    cidr_block              = var.private-app-subnet-2-cidr
    availability_zone       = "us-east-1b"
    map_public_ip_on_launch = false

    tags = {
        Name = "Private Subnet 2 | App Tier"
    } 
}

# Create Private Subnet 1 for Db Tier

resource "aws_subnet" "private-db-subnet-1" {
    vpc_id                  = aws_vpc.vpc_01.id
    cidr_block              = var.private-db-subnet-1-cidr
    availability_zone       = "us-east-1a"
    map_public_ip_on_launch = false

    tags = {
        Name = "Private Subnet 1 | DB Tier"
    } 
}


#Create Private  Subnet 2 for Db Tier
resource "aws_subnet" "private-db-subnet-2" {
    vpc_id                  = aws_vpc.vpc_01.id
    cidr_block              = var.private-db-subnet-2-cidr
    availability_zone       = "us-east-1b"
    map_public_ip_on_launch = false

    tags = {
        Name = "Private Subnet 2 | DB Tier"
    } 
}

# NAT gateway

resource "aws_eip" "eip_nat" {
    #vpc = true

    tags = {
      Name = "eip1"
    }
}

resource "aws_nat_gateway" "nat_1" {
    allocation_id = aws_eip.eip_nat.id
    subnet_id     = aws_subnet.public-web-subnet-2.id

    tags = {

      "Name" = "nat1"
      
    }
}

# Route Table for Private Subnet

resource "aws_route_table" "private-route-table" {
    vpc_id = aws_vpc.vpc_01.id

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.nat_1.id
    }

    tags = {
        Name = "Private Route Table"
    }
  
}

# Route table association for App tier


resource "aws_route_table_association" "nat_route_1" {
    subnet_id       = aws_subnet.private-app-subnet-1.id
    route_table_id  = aws_route_table.private-route-table.id
  
}

resource "aws_route_table_association" "nat_route_2" {
    subnet_id       = aws_subnet.private-app-subnet-2.id
    route_table_id  = aws_route_table.private-route-table.id
  
}


# Route table association for DB tier

resource "aws_route_table_association" "nat_route_db_1" {
    subnet_id       = aws_subnet.private-db-subnet-1.id
    route_table_id  = aws_route_table.private-route-table.id
  
}

resource "aws_route_table_association" "nat_route_db_2" {
    subnet_id       = aws_subnet.private-db-subnet-2.id
    route_table_id  = aws_route_table.private-route-table.id
  
}

# SG Application Load Balancer 

resource "aws_security_group" "alb-security-group" {

    name        = "ALB Security Group"
    description = "Enable http/https access on port 80/443"
    vpc_id      = aws_vpc.vpc_01.id

ingress  {
    description = "http access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
}

ingress  {
    description = "http access"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
}

egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
}

tags = {
    Name = "ALB Security group"

}
}

# SG Application Tier 

resource "aws_security_group" "ssh-security-group" {
    name        = "SSH Access"
    description = "Enable ssh access on port 22"
    vpc_id      = aws_vpc.vpc_01.id

 ingress {
    description = "ssh access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    #cidr_blocks = [var.ssh-locate] 
    cidr_blocks  = ["0.0.0.0/0"]

 } 

 egress {
    from_port    = 0
    to_port      = 0
    protocol     = "-1"
    cidr_blocks  = ["0.0.0.0/0"]   
 }

 tags = {
    Name = "ssh Security Groups"
 }
}

# SG Webserver Tier 

resource "aws_security_group" "webserver-security-group" {

    name        = "Web server Security Group"
    description = "Enable http/https access on port 80/443 via ALB and ssh via ssh sg"
    vpc_id      = aws_vpc.vpc_01.id

  ingress  {
    description = "http access"
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
    security_groups = [aws_security_group.alb-security-group.id]
  } 

  ingress  {
    description = "http access"
    from_port   = "443"
    to_port     = "443"
    protocol    = "tcp"
     security_groups = [aws_security_group.alb-security-group.id]
  }

  ingress  {
    description     = "ssh access"
    from_port       = "22"
    to_port         = "22"
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
   }

   egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
}

tags = {
    Name = "Web server Security group"

}
}

# SG Database Tier

resource  "aws_security_group" "database-security-group" {
    name        = "Database server Security Group"
    description = "Enable MYSQL access on port 3306"
    vpc_id      =  aws_vpc.vpc_01.id

 ingress {
    description = "MYSQLaccess"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.ssh-security-group.id]
 } 

 egress {
    from_port    = 0
    to_port      = 0
    protocol     = "-1"
    cidr_blocks  = ["0.0.0.0/0"]   
 }

 tags = {
    Name = "Database Security Groups"
 }
}

#  Define IAM Role and Policy


resource "aws_iam_role" "s3-access-role" {
  name = "s3-access-role"
  
  assume_role_policy = jsonencode({
   
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "ec2.amazonaws.com"
                
            }
        }
    ]

  })
}

 resource "aws_iam_policy" "s3-full-access-policy" {
  name        = "s3-full-access-policy"
  description = "Policy for full access to S3"

  policy = jsonencode({

 "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:*",
                "s3-object-lambda:*"
            ],
            "Resource": "*"
        }
    ]

  })
} 

resource "aws_iam_role_policy_attachment" "s3-full-access-attachment" {
  policy_arn = aws_iam_policy.s3-full-access-policy.arn
 # policy_arn = "arn:aws:iam::734620144921:policy/s3-full-access-policy"
  role       = aws_iam_role.s3-access-role.name
}

resource "aws_iam_instance_profile" "s3-access-profile" {
  name = "s3-access-profile"
  role = aws_iam_role.s3-access-role.name
 
}





# EC2 instances Web Tier
/* 
 resource "aws_instance" "PublicWebTemplate" {
    ami                     = "ami-0230bd60aa48260c6"
    instance_type           = "t2.micro"
    subnet_id               = aws_subnet.public-web-subnet-1.id
    vpc_security_group_ids = [aws_security_group.webserver-security-group.id]
    key_name                = "asad_practice"
    user_data               = file("install-apache.sh")

    tags = {
      Name = "web-server"
    } 
  }


#EC2 instances app tier

  resource "aws_instance" "private-app-template" {
    ami                     = "ami-0230bd60aa48260c6"
    instance_type           = "t2.micro"
    subnet_id               = aws_subnet.private-app-subnet-1.id 
    vpc_security_group_ids  = [aws_security_group.ssh-security-group.id]
    key_name                = "asad_practice"
    user_data               = file("mysql.sh")
   

    tags = {
      Name = "app-server"
    } 
  }
  
  */

  # AsG for Presentation (Web Server)Tier

  resource "aws_launch_template" "auto-scaling-group" {
    name_prefix       = "auto-scaling-group"
    image_id          = "ami-0230bd60aa48260c6"
    instance_type     = "t2.micro"
    user_data         = base64encode(file("install-apache.sh"))
    key_name          = "asad_practice"
    
     iam_instance_profile {
     name = aws_iam_instance_profile.s3-access-profile.name
     }
  
      network_interfaces {
        subnet_id       = aws_subnet.public-web-subnet-1.id
        security_groups = [aws_security_group.webserver-security-group.id]
      } 
}



    

   /* network_interfaces {
        subnet_id = aws_subnet.public-web-subnet-2.id
        security_groups = [aws_security_group.webserver-security-group.id]
        device_index     = 1
        network_card_index = 1
    } 

    */

  resource "aws_autoscaling_group" "asg-1" {
    availability_zones = ["us-east-1a"]
    desired_capacity = 1
    max_size = 2
    min_size = 1
 
    
    launch_template {
      id = aws_launch_template.auto-scaling-group.id
      version = "$Latest"
    }

}

data "aws_autoscaling_groups" "asgs" {
  names = [aws_autoscaling_group.asg-1.name]
}




# ASG for Application Tier

resource "aws_launch_template" "auto-scaling-group-private" {
    name_prefix     = "auto-scaling-group-private"
    image_id        = "ami-0230bd60aa48260c6"
    instance_type   = "t2.micro"
    user_data       = base64encode(file("mysql.sh"))
    key_name        = "asad_practice"
    
    iam_instance_profile {
     name = aws_iam_instance_profile.s3-access-profile.name
      }
    
    network_interfaces {
        subnet_id = aws_subnet.private-app-subnet-1.id
        security_groups = [aws_security_group.ssh-security-group.id]
    }  
}

  resource "aws_autoscaling_group" "asg-2" {
    availability_zones = ["us-east-1a"]
    desired_capacity = 1
    max_size = 2
    min_size = 1
    
    launch_template {
      id = aws_launch_template.auto-scaling-group-private.id
      version = "$Latest"
    }

}

# Load Balancer

resource "aws_lb" "application-load-balancer" {
    name                              = "web-external-load-balancer"
    internal                          =  false
    load_balancer_type                = "application"
    security_groups                   = [aws_security_group.alb-security-group.id]
    subnets                           = [aws_subnet.public-web-subnet-1.id, aws_subnet.public-web-subnet-2.id]
    enable_deletion_protection        = false  

    /*  access_logs {
    bucket  = aws_s3_bucket.lb_logs.id
    prefix  = "test-lb"
    enabled = true
    }

    */

    

    tags = {
        Name = "App load Balancer"
    }
}

# Create Target Group 

resource "aws_lb_target_group" "alb_target_group" {
    name        = "appbalancertg"
    target_type = "instance"
    port        = 80
    protocol    = "HTTP"
    vpc_id      = aws_vpc.vpc_01.id
}


/* resource "aws_lb_target_group_attachment" "web-attachment" {
    target_group_arn = aws_lb_target_group.alb_target_group.arn
    target_id        = aws_instance.PublicWebTemplate.id
    port             = 80
}
*/

resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name =  aws_autoscaling_group.asg-1.name
 lb_target_group_arn     =  aws_lb_target_group.alb_target_group.arn 

}

/*resource "aws_lb_target_group_attachment" "alb_target_group_attachment" {
  target_group_arn = aws_lb_target_group.alb_target_group.arn
  target_id        = aws_autoscaling_group.asg-1.name# Use the name of your Auto Scaling Group
  port             = 80
}
*/

/*resource "aws_lb_target_group_attachment" "alb_target_group_attachment" {
  target_group_arn = aws_lb_target_group.alb_target_group.arn

  target_id        = aws_autoscaling_group.asg-1.name
  port             = 80
}*/





resource "aws_lb_listener" "alb_http_listener" {
    load_balancer_arn = aws_lb.application-load-balancer.arn
    port              = 80
    protocol          = "HTTP"

    /*default_action {
    type = "fixed-response"
    
    fixed_response {
      content_type = "text/plain"
      status_code  = "200"
      message_body = "OK"
    }
  } */

    default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_target_group.arn
  }
}



   

    
    
    /*default_action {
      type = "redirect"
      
       
       redirect {
        port = 443
        protocol = "HTTPS"
        status_code = "HTTP_301"
      
      }
   }
   */





# database Subnet Group

resource "aws_db_subnet_group" "database-subnet-group" {
    name        = "database subnets"
    subnet_ids  = [aws_subnet.private-db-subnet-1.id, aws_subnet.private-db-subnet-2.id]
    description = "Subnet group for database instances"

    tags = {
        Name = "Database Subnets"
    }
}

# database instance
 
 resource "aws_db_instance" "database-instance" {
        identifier             = "three-tier-db" 
        allocated_storage      = "10"
        engine                 = "mysql"
        engine_version         = "5.7"
        instance_class         = var.database-instance-class 
        db_name                = "sqldb"
        username               = "username"
        password               = "password"
        parameter_group_name   = "default.mysql5.7"
        skip_final_snapshot    = true
        db_subnet_group_name   = aws_db_subnet_group.database-subnet-group.name 
        multi_az               = var.multi-az-deployment
        vpc_security_group_ids = [aws_security_group.database-security-group.id]

         
   
 }

output "lb_dns_name" {
    description = "DNS name of the load balancer"
    value = "${aws_lb.application-load-balancer.dns_name}"
}








