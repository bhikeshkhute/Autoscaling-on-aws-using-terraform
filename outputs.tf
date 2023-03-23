output "Please_Note" {
  value = "The output will take upto five minutes when launched. Keep Refreshing else check LB instance status"
}

output "Visit_This" {
  value = "https://${aws_elb.myelb.dns_name}"
}
