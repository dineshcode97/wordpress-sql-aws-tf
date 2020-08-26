provider "aws" {
  region = "ap-south-1"
  profile = "Dinesh"
}



resource "tls_private_key" "task3key" {
  algorithm = "RSA"
}

resource "aws_key_pair" "genkey" {
  key_name   = "task3key"
  public_key = "${tls_private_key.task3key.public_key_openssh}"


  depends_on = [
    tls_private_key.task3key
  ]
}

resource "local_file" "keystore" {
  content  = "${tls_private_key.task3key.private_key_pem}"
  filename = "task3key.pem"


  depends_on = [
    tls_private_key.task3key
  ]
}




resource "aws_vpc" "myownvpc" {
  cidr_block       = "192.168.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = "true"

  tags = {
    Name = "dinuvpc"
  }
}





resource "aws_security_group" "myfirewall" {
  name        = "myfirewall"
  description = "Allows SSH and HTTP"
  vpc_id      = "${aws_vpc.myownvpc.id}"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
 
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  ingress {
    description = "TCP"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "myfirewall"
  }
}





resource "aws_subnet" "dinusubnet1" {
  vpc_id     = "${aws_vpc.myownvpc.id}"
  cidr_block = "192.168.0.0/24"
  availability_zone = "ap-south-1a"
  map_public_ip_on_launch = "true"
 
  
  tags = {
    Name = "dinusubnet1"
  }
}





resource "aws_subnet" "dinusubnet2" {    
  vpc_id     = "${aws_vpc.myownvpc.id}"
  cidr_block = "192.168.1.0/24"
  availability_zone = "ap-south-1b"
 
  
  tags = {
    Name = "dinusubnet2"
  }
}




resource "aws_internet_gateway" "ingateway" {
  vpc_id = "${aws_vpc.myownvpc.id}"

  tags = {
    Name = "dinugateway"
  }
}




resource "aws_route_table" "route" {
  vpc_id = "${aws_vpc.myownvpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.ingateway.id}"
  }

  tags = {
    Name = "dinuroute"
  }
}





resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.dinusubnet1.id
  route_table_id = aws_route_table.route.id
}
resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.dinusubnet2.id
  route_table_id = aws_route_table.route.id
}





resource "aws_instance" "os1" {
	ami = "ami-38146557"
	instance_type = "t2.micro"
	key_name = aws_key_pair.genkey.key_name
	vpc_security_group_ids = [aws_security_group.myfirewall.id]
    subnet_id = "${aws_subnet.dinusubnet1.id}"
  #   	  provisioner "remote-exec" {
	#     inline = [
	#       "sudo yum install php-mysqlnd php-fpm httpd tar curl php-json -y",
	#       "sudo systemctl restart httpd",
	#       "sudo systemctl enable httpd",
  #       "sudo curl https://wordpress.org/latest.tar.gz --output wordpress.tar.gz",
  #       "sudo tar xf wordpress.tar.gz",
  #       "sudo cp -r wordpress /var/www/html",
  #       "sudo chown -R apache:apache /var/www/html/wordpress",
  #       "sudo chcon -t httpd_sys_rw_content_t /var/www/html/wordpress -R",

	#     ]
	# }

  
tags = {
	Name = "dinuWordpress"
	}
   }




resource "aws_instance" "os2" {
	ami = "ami-08706cb5f68222d09"
	instance_type = "t2.micro"
	key_name = aws_key_pair.genkey.key_name
	vpc_security_group_ids = [aws_security_group.myfirewall.id]
     subnet_id = "${aws_subnet.dinusubnet2.id}"
tags = {
	Name = "dinuMysql"
	}
   }
