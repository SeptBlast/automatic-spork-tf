# New Certificate Creation
resource "aws_acm_certificate" "clientdomain_com" {
  domain_name       = "tf.clientdomain.com"
  validation_method = "DNS"

  tags = {
    Environment = "production"
    Cleint      = "ProjectName"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Import Certificate
resource "tls_private_key" "clientdomain_com_key" {
  algorithm           = "RSA"
  rsa_bits            = 2048
  allow_rsa_key_reuse = true
}

resource "tls_self_signed_cert" "clientdomain_com_cert" {
  key_algorithm   = "RSA"
  private_key_pem = tls_private_key.clientdomain_com_key.private_key_pem

  subject {
    common_name  = "tf.clientdomain.com"
    organization = "ACME"
  }

  validity_period_hours = 24

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "aws_acm_certificate" "new_cert" {
  private_key      = tls_private_key.clientdomain_com_key.private_key_pem
  certificate_body = tls_self_signed_cert.clientdomain_com_cert.cert_pem
}
