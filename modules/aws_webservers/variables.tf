# Instance type
variable "instance_type" {
  default = {
    "prod"    = "t2.micro"
    "test"    = "t2.micro"
    "staging" = "t2.micro"
  }
  description = "Type of the instance"
  type        = map(string)
}

# Default tags
variable "default_tags" {
  default = {
    "Owner" = "Surojit Rakshit"
    "App"   = "Web"
  }
  type        = map(any)
  description = "Default tags to be appliad to all AWS resources"
}

# Prefix to identify resources
variable "prefix" {
  default     = "project2"
  type        = string
  description = "Name prefix"
}

variable "prefix1" {
  default     = "webserver1"
  type        = string
  description = "Name prefix"
}

variable "prefix2" {
  default     = "webserver2"
  type        = string
  description = "Name prefix"
}

variable "prefix3" {
  default     = "Bastion"
  type        = string
  description = "Name prefix"
}

# Variable to signal the current environment 
variable "env" {
  default     = "test"
  type        = string
  description = "Deployment Environment"
}



