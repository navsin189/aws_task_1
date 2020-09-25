# aws_task_1
creating terraform code to launch aws ec2 instance.
Problem Statement:

To create a infrastructure using terraform in aws cloud in which an instance will be created and then we create a volume and attach it with the instance we created then we format the volume we attached and mount it to the web folder /var/www/html. while doing so we also install httpd , php and copy the code in the folder we mounted in newly created volume remotely through github. Also we will create an s3 bucket and upload an image in it and after that we create a cloudfront to make the link faster and then use that link in the code of github and use the code to launch the site.
Stepwise Solution:
1. Provide the region and profile through which we create infrastructure :
  provider "aws" {
  region     = "ap-south-1"
  profile    = "user1"
  }
2. Create a security group through code and give http , https and ssh ports :
   resource "aws_security_group" "securitygp" {
  name        = "awstask1"
  description = "Allow TLS inbound traffic"

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
 
ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
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
3. Create an instance and remotely download and install httpd, php, git, and enable the services:
   resource "aws_instance" "trial" {
  ami           = "ami-0447a12f28fddb066"
  instance_type = "t2.micro"
  key_name      = "awskey"
  security_groups = ["awstask1"]

   connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("C:/Users/Furious/Downloads/awskey.pem")
    host     =  aws_instance.trial.public_ip
  }
  


 provisioner "remote-exec" {
    inline = [
      "sudo yum install httpd php git -y",
      "sudo systemctl restart httpd",
      "sudo systemctl enable httpd",
    ]
  }
  
  tags = {
    Name = "ec2_os"
  }

}
4. Creating new volume and attaching it to the instance we created.
5. Creating cloud front and updating the github code by providing the cloudfront link on it.
6. Formatting the new volume and mounting it on the folder /var/www/html and copying the code from github and launching the site on chrome remotely.
7. chrome will be executed then webpage that was deployed opens.

