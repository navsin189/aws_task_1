provider "aws" {
  region     = "ap-south-1"
  profile    = "user1"
}

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

resource "aws_ebs_volume" "vol" {
  availability_zone = aws_instance.trail.availability_zone
  size              = 1

  tags = {
    Name = "extra"
  }
}

resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdd"
  volume_id   = aws_ebs_volume.vol.id
  instance_id = aws_instance.trial.id
}



output "out1"{
 value= aws_instance.trial.public_ip
}

resource "null_resource" "null" {
   provisioner "local-exec" {
    command = "echo ${aws_instance.trial.public_ip} > publicip.txt"
  }
 }




resource "null_resource" "formathd" {
 depends_on = [
   aws_volume_attachment.ebs_att,
  ]

  connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("C:/Users/Furious/Downloads/awskey.pem")
    host     =  aws_instance.trial.public_ip
  }
  


 provisioner "remote-exec" {
    inline = [
      "sudo mkfs.ext4 /dev/xvdh",
      "sudo mount /dev/xvdh  /var/www/html",
      "sudo rm -rf /var/www/html/*",
      "sudo git clone https://github.com/navsin189/taske.git /var/www/html"
    ]
  }
}



resource "null_resource" "openchrome" {
 depends_on = [
   null_resource.formathd,
  ]
provisioner "local-exec" {
    command = "start chrome ${aws_instance.trial.public_ip}"
  }
 }


