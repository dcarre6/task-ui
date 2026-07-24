#################################################
# Terraform y proveedor AWS
#################################################

terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

#################################################
# Bucket S3 donde vivirá el frontend
#################################################

resource "aws_s3_bucket" "frontend" {
  # El nombre debe ser único globalmente
  bucket = "task-ui-dcarre6-267693165925"
}

#################################################
# Bloquear acceso público directo al bucket
#
# Queremos que los usuarios entren por:
# CloudFront
#
# NO por:
# https://bucket.s3.amazonaws.com
#################################################

resource "aws_s3_bucket_public_access_block" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

#################################################
# Origin Access Control
#
# Le dice a AWS:
#
# "CloudFront puede acceder al bucket"
#
# Es el mecanismo moderno.
#################################################

resource "aws_cloudfront_origin_access_control" "frontend" {

  name        = "task-ui-oac"
  description = "Access for Task UI"

  origin_access_control_origin_type = "s3"

  signing_behavior = "always"

  signing_protocol = "sigv4"
}

#################################################
# CloudFront
#
# Es la URL pública:
#
# https://xxxx.cloudfront.net
#################################################

resource "aws_cloudfront_distribution" "frontend" {

  enabled = true

  default_root_object = "index.html"

  #################################################
  # Origin
  #
  # ¿De dónde obtiene los archivos?
  #
  # Del bucket S3.
  #################################################

  origin {

    domain_name = aws_s3_bucket.frontend.bucket_regional_domain_name

    origin_id = "frontend-s3"

    origin_access_control_id = aws_cloudfront_origin_access_control.frontend.id
  }

  #################################################
  # Comportamiento por defecto
  #################################################

  default_cache_behavior {

    target_origin_id = "frontend-s3"

    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = [
      "GET",
      "HEAD"
    ]

    cached_methods = [
      "GET",
      "HEAD"
    ]

    forwarded_values {

      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  #################################################
  # Sin restricciones geográficas
  #################################################

  restrictions {

    geo_restriction {
      restriction_type = "none"
    }
  }

  #################################################
  # Certificado HTTPS administrado por AWS
  #################################################

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

#################################################
# Política del bucket
#
# Permite que CloudFront lea los archivos.
#
# Y solo CloudFront.
#################################################

data "aws_iam_policy_document" "frontend_bucket_policy" {

  statement {

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${aws_s3_bucket.frontend.arn}/*"
    ]

    principals {

      type = "Service"

      identifiers = [
        "cloudfront.amazonaws.com"
      ]
    }

    condition {

      test = "StringEquals"

      variable = "AWS:SourceArn"

      values = [
        aws_cloudfront_distribution.frontend.arn
      ]
    }
  }
}

resource "aws_s3_bucket_policy" "frontend" {

  bucket = aws_s3_bucket.frontend.id

  policy = data.aws_iam_policy_document.frontend_bucket_policy.json
}