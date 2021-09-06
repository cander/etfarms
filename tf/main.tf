# inspired by https://www.alexhyett.com/terraform-s3-static-website-hosting/
locals {
    bare_domain_name = "etfarms.com"
    region  	     = "us-west-2"
    spf	             = "v=spf1 include:_spf.forwardmx.io -all"
    mx1	             = "mx1.forwardmx.io"
    mx2              = "mx2.forwardmx.io"
    ttl		     = 900
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.55"
    }
  }

  required_version = ">= 1.0.5"
}

provider "aws" {
  profile = "cander"
  region = local.region
}

resource "aws_s3_bucket" "bare_bucket" {
    bucket = local.bare_domain_name
    acl    = "public-read"
    website {
	index_document = "index.html"
    }
}

# www redirects to bare domain
resource "aws_s3_bucket" "www_bucket" {
    bucket = "www.${local.bare_domain_name}"
    acl    = "public-read"
    website {
	    redirect_all_requests_to = "https://${local.bare_domain_name}"
    }
}

resource "aws_route53_zone" "main" {
  name = local.bare_domain_name
}

# hosting records
resource "aws_route53_record" "bare-a" {
  zone_id = aws_route53_zone.main.zone_id
  name    = local.bare_domain_name
  type    = "A"

  alias {
    name                   = aws_s3_bucket.bare_bucket.website_domain
    zone_id                = aws_s3_bucket.bare_bucket.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "www-a" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "www.${local.bare_domain_name}"
  type    = "A"

  alias {
    name                   = aws_s3_bucket.www_bucket.website_domain
    zone_id                = aws_s3_bucket.www_bucket.hosted_zone_id
    evaluate_target_health = false
  }
}

# mail records
resource "aws_route53_record" "mx" {
  zone_id = aws_route53_zone.main.zone_id
  name    = ""
  type    = "MX"
  ttl     = local.ttl
  records = [
        "10 ${local.mx1}",
	"20 ${local.mx2}"
  ]
}
resource "aws_route53_record" "spf" {
  zone_id = aws_route53_zone.main.zone_id
  name    = ""
  type    = "TXT"
  ttl     = local.ttl
  records = [
         local.spf
  ]
}
