terraform {
  backend "s3" {
    bucket = "projectf-webserver"          // Bucket from where to GET Terraform State
    key    = "webserver/terraform.tfstate" // Object name in the bucket to GET Terraform State
    region = "us-east-1"                   // Region where bucket created
  }
}