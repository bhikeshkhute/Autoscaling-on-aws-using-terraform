#--------------
#CONFIGURE AWS CONNECTION
#--------------

provider "aws" {
  region = var.region
}
#--------------
# Create a VPC
#--------------

resource "aws_vpc" "vpcautoscale" {
  cidr_block       = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    Name = "VPC-AUTOSCALE"
  }
}

#-------------------------------------------------
# Create a Public subnet on the First available AZ
#-------------------------------------------------

resource "aws_subnet" "public_ap_south_1a" {
  vpc_id     = aws_vpc.vpcautoscale.id
  availability_zone = var.avzone
  map_public_ip_on_launch = "true" #Since we need internet connectivity post instances launch, we are enabling the same right now.
  cidr_block = var.subnet_cidr
  tags = {
    Name = "SUBNET-AUTOSCALE"
  }
}

#-----------------------------------------------------------
# CREATE THE SECURITY GROUP THAT'S APPLIED TO Web Server EC2
#-----------------------------------------------------------

resource "aws_security_group" "securityautos" {
  name = "security-group-autos"
  vpc_id = aws_vpc.vpcautoscale.id

  # Allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Inbound for SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Inbound for Web server
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#-------------------------------
# Create an IGW for your new VPC
#-------------------------------
resource "aws_internet_gateway" "autoscale_igw" {
  vpc_id = aws_vpc.vpcautoscale.id

  tags = {
    Name = "AUTOSCALE-IGW"
  }
}

#----------------------------------
# Create an RouteTable for your VPC
#----------------------------------
resource "aws_route_table" "my_vpc_public" {
    vpc_id = aws_vpc.vpcautoscale.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.autoscale_igw.id
    }

    tags = {
        Name = "AUTOSCALE-ROUTETABLE"
    }
}

#--------------------------------------------------------------
# Associate the RouteTable to the Subnet created at ap-south-1a
#--------------------------------------------------------------
resource "aws_route_table_association" "my_vpc_ap_south_1a_public" {
    subnet_id = aws_subnet.public_ap_south_1a.id
    route_table_id = aws_route_table.my_vpc_public.id
}
#-----------------------------
# Creating Launch Template
#-----------------------------

resource "aws_launch_template" "autoscalelaunch"{
	vpc_security_group_ids=[aws_security_group.securityautos.id]
	placement{
		availability_zone = "ap-south-1a"
	}
	image_id = var.ami_id
	instance_type = var.instancetype
	user_data = filebase64("user-data.sh")
}


#----------------------------
# Creating Classic ELB FOR FRONT END
#----------------------------

resource "aws_elb" "myelb"{
	subnets=[aws_subnet.public_ap_south_1a.id]
	security_groups=[aws_security_group.securityautos.id]
        health_check{
        target="HTTP:80/"
        interval=30
        timeout=3
        healthy_threshold=2
        unhealthy_threshold=2
        }

        listener{
        lb_port=80
        lb_protocol="http"
        instance_port=80
        instance_protocol="http"
        }
}


#----------------------------
# Creating AutoScaling Group
#----------------------------

resource "aws_autoscaling_group" "asgwebservix"{
        name="asgwebservix"
        vpc_zone_identifier=[aws_subnet.public_ap_south_1a.id]
        launch_template{
        id=aws_launch_template.autoscalelaunch.id
        }
        min_size=var.min_instance
        max_size=var.max_instance
        load_balancers=[aws_elb.myelb.name]
        health_check_type="EC2"
        tag{
        key="AWSAuto"
        value="bybhikesh"
        propagate_at_launch=true
        }

}

#----------------------------------------------------------------------
# Creating AutoScaling Policy & Cloudwatch Metric Alarm For Scaling Up
#----------------------------------------------------------------------

resource "aws_autoscaling_policy" "scale_up" {
  name="Scaleup"
  autoscaling_group_name = aws_autoscaling_group.asgwebservix.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = var.cooldown
}

resource "aws_cloudwatch_metric_alarm" "scale_upp" {
  alarm_description   = "Monitors CPU utilization for ASG"
  alarm_actions       = [aws_autoscaling_policy.scale_up.arn]
  alarm_name          = "Scaleup"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  threshold           = var.threshold
  evaluation_periods  = var.eval_period
  period              = var.period
  statistic           = "Average"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asgwebservix.name
  }
}

#------------------------------------------------------------------------
# Creating AutoScaling Policy & Cloudwatch Metric Alarm For Scaling down
#-------------------------------------------------------------------------

resource "aws_autoscaling_policy" "scale_down" {
  name="Scaledown"
  autoscaling_group_name = aws_autoscaling_group.asgwebservix.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = var.cooldown
}

resource "aws_cloudwatch_metric_alarm" "scale_downn" {
  alarm_description   = "Monitors CPU utilization for ASG"
  alarm_actions       = [aws_autoscaling_policy.scale_down.arn]
  alarm_name          = "Scaledown"
  comparison_operator = "LessThanOrEqualToThreshold"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  threshold           = var.threshold
  evaluation_periods  = var.eval_period
  period              = var.period
  statistic           = "Average"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asgwebservix.name
  }
}

