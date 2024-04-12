# Provisioning AWS Infrastructure & Autoscaling using Terraform 

Terraform is an open-source infrastructure-as-code software tool to create infrastructure using a declarative configuration language. 

In this project, we'll create AWS resources i.e., VPC,Subnet,Security Groups,Internet Gateway, Route Tables,Load Balancers,Launch Templates, Auto Scaling groups, policies and cloud watch metrics. 

The objective of this project is to dynamically create resources in a declarative way and simulate autoscaling in response to traffic/resource consumption(CPU Utiliation>40%).


![Architecture Diagram](https://github.com/norfluxX/Autoscaling-on-aws-using-terraform/assets/35907619/a80430c8-b0d5-404e-ac3d-d4796d01fe18)

## Want to give a try on your system? Follow the steps below.

We have three files and it is described as:
1. main.tf - All the resources declared here in the creation orders.

2. variables.tf - We can change the values the defined in the main file without touching the main file from this file. We can tune it according to our requirements.

3. outputs.tf - The endpoint/website URL will be shown as output once resources are created.

Steps:

1. Create your access keys. Click on the right top corner on your account and select "Security Credentials".

2. Scroll down to "Access keys" section and create the same and copy it to a file for future references(Don't share with anyone).

3. Now,we'll install terraform,awscli and git as a prerequisite. 

    ```
    sudo apt update && sudo apt install terraform awscli git -y 
    ```
4. Once done, run the following command:

    ``` 
    awsconfigure 
    ```
      AWS Access Key ID - !<paste your access key which was copied earlier in step 2>!

      AWS Secret Access Key - !<paste your secret key created in step 2>!

      Default region name - ap-south-1

      Default output format - json

5. Now, clone the project using the following command 

    ``` 
    git clone https://github.com/bhikeshkhute/Autoscaling-on-aws-using-terraform.git
    ```

6. Now go inside the folder and run the command:

    Initializing Terraform files
    ```
    terraform init
    ```

    Validating the terraform files
    ```
    terraform validate 
    ```
  
    Let's See the plan what will be created
    ```
    terraform plan
    ```

    Once plan is ok, we'll create the same auto approved
    ``` 
    terraform apply -auto-approve 
    ```

Wait for some time to create all the resource. You can also visit the AWS console to see all the resources. 

## Simulation of AutoScaling. 

Take access of the instance created using autoscaling and install stress command to increase the CPU utilization > 40%

```
sudo apt install stress -y
```

Now, run to stress the machine so one more machine will be deployed within 2 minutes.
```
stress -c 2 -i 1 -m 1 --vm-bytes 256M -t 500s
```
Wait for atleast 5 minutes to see the changes. 

Once everything is deployed. You can destroy everything in one go using the following command

```
terraform destroy -auto-approve
```

