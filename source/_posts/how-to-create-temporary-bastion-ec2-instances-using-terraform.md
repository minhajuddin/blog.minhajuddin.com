title: How to create temporary bastion EC2 instances using Terraform
date: 2020-05-06 12:02:47
tags:
- Terraform
- Bastion
- EC2
- AWS
- SSH
- ProxyJump
---

I have recently started learning Terraform to manage my AWS resources, And it is
a great tool for maintaining your infrastructure! I use a [Bastion
host](https://en.wikipedia.org/wiki/Bastion_host) to SSH into my main servers
and bring up the bastion host on demand only when I need it giving me some cost
savings. Here are the required Terraform files to get this working.

Set up the `bastion.tf` file like so:

```hcl
# get a reference to aws_ami.id using a data resource by finding the right AMI
data "aws_ami" "ubuntu" {
  # pick the most recent version of the AMI
  most_recent = true

  # Find the 20.04 image
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  # With the right virtualization type
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  # And the image should be published by Canonical (which is a trusted source)
  owners = ["099720109477"] # Canonical's owner_id don't change this
}

# Configuration for your bastion EC2 instance
resource "aws_instance" "bastion" {
  # Use the AMI from the above step
  ami = data.aws_ami.ubuntu.id

  # We don't need a heavy duty server, t2.micro should suffice
  instance_type = "t2.micro"

  # We use a variable which can be set to true or false in the terraform.tfvars
  # file to control creating or destroying the bastion resource on demand.
  count = var.bastion_enabled ? 1 : 0

  # The ssh key name
  key_name = var.ssh_key_name

  # This should refer to the subnet in which you want to spin up the Bastion host
  # You can even hardcode this ID by getting a subnet id from the AWS console
  subnet_id = aws_subnet.subnet[0].id

  # The 2 security groups here have 2 important rules
  # 1. hn_bastion_sg: opens up Port 22 for just my IP address
  # 2. default: sets up an open network within the security group
  vpc_security_group_ids = [aws_security_group.hn_bastion_sg.id, aws_default_security_group.default.id]

  # Since we want to access this via internet, we need a public IP
  associate_public_ip_address = true

  # Some useful tags
  tags = {
    Name = "Bastion"
  }
}

# We want to output the public_dns name of the bastion host when it spins up
output "bastion-public-dns" {
  value = var.bastion_enabled ? aws_instance.bastion[0].public_dns : "No-bastion"
}
```

Set up the `terraform.tfvars` file like so:
```hcl
# Set this to `true` and do a `terraform apply` to spin up a bastion host
# and when you are done, set it to `false` and do another `terraform apply`
bastion_enabled = false

# My SSH keyname (without the .pem extension)
ssh_key_name = "hyperngn_aws_ohio"

# The IP of my computer. Do a `curl -sq icanhazip.com` to get it
# Look for the **ProTip** down below to automate this!
myip = ["247.39.103.23/32"]

```

Set up the `vars.tf` file like so:
```hcl
variable "ssh_key_name" {
  description = "Name of AWS key pair"
}

variable "myip" {
  type        = list(string)
  description = "My IP to allow SSH access into the bastion server"
}

variable "bastion_enabled" {
  description = "Spins up a bastion host if enabled"
  type        = bool
}
```

Relevant sections from my `vpc.tf`, you could just hardcode these values in the
`bastion.tf` or use `data` if you've set these up manually and `resources` if
you use terraform to control them

```
resource "aws_subnet" "subnet" {
  # ...
}

# Allows SSH connections from our IP
resource "aws_security_group" "hn_bastion_sg" {
  name   = "hn_bastion_sg"
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.myip
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

# Allow inter security group connections
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.vpc.id

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```


Finally you need to set up your ~/.ssh/config to use the bastion as the jump
host like so:

```
# Bastion config
Host bastion
# Change the hostname to whatever you get from terraform's output
Hostname ec2-5-55-128-160.us-east-2.compute.amazonaws.com
IdentityFile ~/.ssh/hyperngn_aws_ohio.pem

# ECS cluster machines
Host ecs1
Hostname 20.10.21.217
User ec2-user
IdentityFile ~/.ssh/hyperngn_aws_ohio.pem
ForwardAgent yes
ProxyJump bastion

# This section is optional but allows you to reuse SSH connections
Host *
  User ubuntu
   Compression yes
# every 10 minutes send an alive ping
   ServerAliveInterval 60
   ControlMaster auto
   ControlPath /tmp/ssh-%r@%h:%p
```

Once you are done, you can just login by running the following command and it
should run seamlessly:

```
ssh ecs1
```

**Pro-Tip** Put the following in your terraform folder's .envrc, so that you
don't have to manually copy paste your IP every time you bring your bastion host
up (You also need to have [direnv](https://direnv.net/) for this to work).
~~~
$ cat .envrc
export TF_VAR_myip="[\"$(curl -sq icanhazip.com)/32\"]"
~~~

## Gotchas
 1. If you run into any issues use the `ssh -vv ecs1` command to get copious
    logs and read through all of them to figure out what might be wrong.
 2. Make sure you are using the correct `User`, Ubuntu AMIs create a user called
    `ubuntu` whereas Amazon ECS optimized AMIs create an `ec2-user` user, If you
    get the user wrong `ssh` will fail.
 3. Use private IPs for the target servers that you are jumping into and the
    public IP or public DNS for your bastion host.
 4. Make sure your Bastion host is in the same VPC with a default security group
    which allows inter security group communication and a security group which
    opens up the SSH port for your IP. If they are not on the same VPC make sure
    they have the right security groups to allow communication from the bastion
    host to the target host, specifically on port 22. You can use VPC flow logs
    to figure problems in your network.

From a security point of view this is a pretty great set up, your normal servers
don't allow any SSH access (and in my case aren't even public and are fronted by
ALBs). And your bastion host is not up all the time, and even when it is up, it
only allows traffic from your single IP. It also saves cost by tearing down the
bastion instance when you don't need it.


