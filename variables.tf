variable "domain_name" {
  type    = string
  default = "example.com"
}

variable "avaibility_zone_name" {
  type    = list(string)
  default = ["ap-south-1", "us-east-1"]
}
