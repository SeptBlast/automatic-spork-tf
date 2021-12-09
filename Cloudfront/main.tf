# CloudFront distributions take about 15 minutes to a deployed state after creation or modification. During this time, deletes to resources will be blocked. If you need to delete a distribution that is enabled and you do not want to wait, you need to use the retain_on_delete flag.

resource "aws_s3_bucket" "production_s3_assets_bucket" {
  bucket = "tf-test-bucket-%d"
  acl    = "public-read"

  lifecycle {
    rule {
      id      = "id1"
      prefix  = "assets"
      enabled = true

      expiration {
        days = 365
      }
    }
  }

  tags = {
    "ENV" = "production"
  }

  tags_all = {
    "Name" = "production_s3_assets_bucket"
  }
}

locals {
  s3_origin_id      = "my-s3-origin"
  kit_proxy_lb      = "kit-proxy-lb"
  s3_grp_origin_id  = "my-s3-group-origin"
  s3_prim_origin_id = "my-s3-primary-origin"
  s3_fail_origin_id = "my-s3-failover-origin"
}

resource "aws_cloudfront_distribution" "Client_Cloudfront_Instance" {
  origin {
    domain_name = aws_s3_bucket.production_s3_assets_bucket.id
    origin_path = "/<PROJECT_ID>/"
    origin_id   = local.s3_origin_id

    s3_origin_config {
      origin_access_identity = aws_iam_role.CloudFront_Instance.arn
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CloudFront distribution for assets for client production Env"
  default_root_object = ""

  logging_config {
    include_cookies = false
    bucket          = "production_s3_logs_bucket"
    prefix          = "<CLIENT_NAME | ENV>"
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS", "PUT", "PATCH", "POST", "DELETE"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  # Cache behavior with precedence 0
  ordered_cache_behavior {
    path_pattern     = "/content/immutable/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false
      headers      = ["Origin"]

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  # Cache behavior with precedence 1
  ordered_cache_behavior {
    path_pattern     = "/content/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = local.kit_proxy_lb

    forwarded_values {
      query_string = false
      headers      = ["Origin"]

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "IN", "GB"]
    }
  }

  tags = {
    "ENV"   = "PRODUCTION"
    "CLENT" = "CLIENT_NAME"
  }

  viewer_certificate {
    cloudfront_default_certificate = false
    certificate                    = "<CLIENT_CERTIFICATE_ARN>"
  }

}

resource "aws_cloudfront_distribution" "Client_Cloudfront_Instance" {
  origin_group {
    origin_id = local.s3_grp_origin_id

    failover_criteria {
      status_codes = [403, 404, 405, 500, 502, 503, 504]
    }

    members {
      origin_id = local.s3_prim_origin_id
    }

    members {
      origin_id = local.s3_fail_origin_id
    }
  }

  origin {
    domain_name = aws_s3_bucket.primary.bucket_regional_domain_name
    origin_path = "/<PROJECT_ID>/"
    origin_id   = local.s3_prim_origin_id

    s3_origin_config {
      origin_access_identity = aws_iam_role.CloudFront_Instance.arn
    }
  }

  origin {
    domain_name = aws_s3_bucket.failover.bucket_regional_domain_name
    origin_path = "/<PROJECT_ID>/"
    origin_id   = local.s3_fail_origin_id

    s3_origin_config {
      origin_access_identity = aws_iam_role.CloudFront_Instance.arn
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CloudFront distribution for assets for client production Env"
  default_root_object = ""

  logging_config {
    include_cookies = false
    bucket          = "production_s3_logs_bucket"
    prefix          = "<CLIENT_NAME | ENV>"
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS", "PUT", "PATCH", "POST", "DELETE"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  # Cache behavior with precedence 0
  ordered_cache_behavior {
    path_pattern     = "/content/immutable/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false
      headers      = ["Origin"]

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  # Cache behavior with precedence 1
  ordered_cache_behavior {
    path_pattern     = "/content/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = local.kit_proxy_lb

    forwarded_values {
      query_string = false
      headers      = ["Origin"]

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "IN", "GB"]
    }
  }

  tags = {
    "ENV"   = "PRODUCTION"
    "CLENT" = "CLIENT_NAME"
  }

  viewer_certificate {
    cloudfront_default_certificate = false
    certificate                    = "<CLIENT_CERTIFICATE_ARN>"
  }

}
