locals {
  services = {
    ssm = {
      service_name = "com.amazonaws.ap-northeast-1.ssm"
      type         = "Interface"
      policy       = data.aws_iam_policy_document.vpc_endpoint.json
    },
    ec2messages = {
      service_name = "com.amazonaws.ap-northeast-1.ec2messages"
      type         = "Interface"
      policy       = data.aws_iam_policy_document.vpc_endpoint.json
    },
    ssmmessages = {
      service_name = "com.amazonaws.ap-northeast-1.ssmmessages"
      type         = "Interface"
      policy       = data.aws_iam_policy_document.vpc_endpoint.json
    },
    s3 = {
      service_name = "com.amazonaws.ap-northeast-1.s3"
      type         = "Gateway"
      policy       = data.aws_iam_policy_document.vpc_endpoint.json
    },
  }
}

data "aws_iam_policy_document" "vpc_endpoint" {
  statement {
    effect    = "Allow"
    actions   = ["*"]
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}

resource "aws_vpc_endpoint" "vpc_endpoint" {
  for_each = local.services

  vpc_id = aws_vpc.vpc.id

  service_name      = each.value.service_name
  vpc_endpoint_type = each.value.type

  subnet_ids          = each.value.type == "Interface" ? [aws_subnet.subnet["private_subnet_1a"].id, aws_subnet.subnet["private_subnet_1c"].id] : null
  security_group_ids  = each.value.type == "Interface" ? [aws_security_group.sg[local.ssm_sg].id] : null
  private_dns_enabled = each.value.type == "Interface" ? true : null
}
