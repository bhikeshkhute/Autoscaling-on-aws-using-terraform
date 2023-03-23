variable "region"{
	default="ap-south-1"
}

variable "vpc_cidr"{
	default="10.0.0.0/16"
}

variable "avzone"{
	default="ap-south-1a"
}

variable "subnet_cidr"{
	default="10.0.0.0/24"
}

#Forlaunchtemplate
variable "ami_id"{
	default="ami-0caf778a172362f1c"
}

variable "instancetype"{
	default="t2.micro"
}

#ASG
variable "min_instance"{
	default=1
}

variable "max_instance"{
	default=2
}

#ASG_P&CLoudMetric

variable "cooldown"{
	default=60
}

variable "threshold"{
	default=40
}

variable "eval_period"{
	default=2
}

variable "period"{
	default=60
}
