terraform {
  backend "s3" {
    bucket = "mahi-terraform-state"
    key = "lambdas"
    region = "us-west-2"
  }
}
