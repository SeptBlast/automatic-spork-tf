data "aws_acm_certificate" "issued" {
  domain   = "tf.client_domain.com"
  statuses = ["ISSUED", "INACTIVE"]
}

data "aws_acm_certificate" "amazon__issued" {
  domain      = "tf.client_domain.com"
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}

data "aws_acm_certificate" "rsa__4096" {
  domain    = "tf.client_domain.com"
  key_types = ["RSA_4096"]
}

