locals {

  front_alb_sg   = "front_alb_sg"
  gin_nlb_sg    = "gin_nlb_sg"
  gin_server_sg = "gin_server_sg"
  next_server_sg = "next_server_sg"
  ssm_sg         = "ssm_sg"

  security_groups = {
    "${local.front_alb_sg}" = {
      ingress = [
        {
          ip_protocol                    = "tcp"
          from_port                      = 80
          to_port                        = 80
          cidr_ipv4                      = var.any_ipv4
          referenced_security_group_name = ""
        },
        {
          ip_protocol                    = "tcp"
          from_port                      = 443
          to_port                        = 443
          cidr_ipv4                      = var.any_ipv4
          referenced_security_group_name = ""
        },
      ],
      egress = [
        {
          ip_protocol                    = "tcp"
          from_port                      = 3000
          to_port                        = 3000
          cidr_ipv4                      = ""
          referenced_security_group_name = local.next_server_sg
        },
        {
          ip_protocol                    = "tcp"
          from_port                      = 80
          to_port                        = 80
          cidr_ipv4                      = ""
          referenced_security_group_name = local.gin_nlb_sg
        },
      ],
    },
    "${local.gin_nlb_sg}" = {
      ingress = [
        {
          ip_protocol                    = "tcp"
          from_port                      = 80
          to_port                        = 80
          cidr_ipv4                      = ""
          referenced_security_group_name = local.next_server_sg
        },
        {
          ip_protocol                    = "tcp"
          from_port                      = 80
          to_port                        = 80
          cidr_ipv4                      = ""
          referenced_security_group_name = local.front_alb_sg
        },
      ],
      egress = [
        {
          ip_protocol                    = "tcp"
          from_port                      = 80
          to_port                        = 80
          cidr_ipv4                      = ""
          referenced_security_group_name = local.gin_server_sg
        },
      ],
    },
    "${local.gin_server_sg}" = {
      ingress = [
        {
          ip_protocol                    = "tcp"
          from_port                      = 80
          to_port                        = 80
          cidr_ipv4                      = ""
          referenced_security_group_name = local.front_alb_sg
        },
        {
          ip_protocol                    = "tcp"
          from_port                      = 80
          to_port                        = 80
          cidr_ipv4                      = ""
          referenced_security_group_name = local.gin_nlb_sg
        },
      ],
      egress = [
        {
          ip_protocol                    = "tcp"
          from_port                      = 80
          to_port                        = 80
          cidr_ipv4                      = ""
          referenced_security_group_name = local.gin_nlb_sg
        },
        {
          ip_protocol                    = "tcp"
          from_port                      = 443
          to_port                        = 443
          cidr_ipv4                      = var.any_ipv4
          referenced_security_group_name = ""
        },
      ],
    },
    "${local.next_server_sg}" = {
      ingress = [
        {
          ip_protocol                    = "tcp"
          from_port                      = 3000
          to_port                        = 3000
          cidr_ipv4                      = ""
          referenced_security_group_name = local.front_alb_sg
        },
      ],
      egress = [
        {
          ip_protocol                    = "tcp"
          from_port                      = 80
          to_port                        = 80
          cidr_ipv4                      = ""
          referenced_security_group_name = local.gin_nlb_sg
        },
        {
          ip_protocol                    = "tcp"
          from_port                      = 443
          to_port                        = 443
          cidr_ipv4                      = var.any_ipv4
          referenced_security_group_name = ""
        },
      ],
    },
    "${local.ssm_sg}" = {
      ingress = [
        {
          ip_protocol                    = "tcp"
          from_port                      = 443
          to_port                        = 443
          cidr_ipv4                      = var.vpc_cidr_block
          referenced_security_group_name = ""
        },
      ],
      egress = [],
    }
  }
}

resource "aws_security_group" "sg" {

  for_each = local.security_groups

  vpc_id = aws_vpc.vpc.id
  name   = each.key
}

locals {
  ingress = flatten([
    for k, v in local.security_groups : [
      for i in v.ingress : {
        security_group_name            = k
        from_port                      = i.from_port
        to_port                        = i.to_port
        protocol                       = i.ip_protocol
        cidr_ipv4                      = i.cidr_ipv4
        referenced_security_group_name = i.referenced_security_group_name
      }
    ]
  ])

  egress = flatten([
    for k, v in local.security_groups : [
      for e in v.egress : {
        security_group_name            = k
        from_port                      = e.from_port
        to_port                        = e.to_port
        protocol                       = e.ip_protocol
        cidr_ipv4                      = e.cidr_ipv4
        referenced_security_group_name = e.referenced_security_group_name
      }
    ]
  ])
}

resource "aws_vpc_security_group_ingress_rule" "sg_ingress_rule" {

  for_each = { for v in local.ingress : "${v.security_group_name}_ingress_${v.from_port}_${v.to_port}_${v.cidr_ipv4}_${v.referenced_security_group_name}" => v }

  security_group_id            = aws_security_group.sg[each.value.security_group_name].id
  from_port                    = each.value.from_port
  to_port                      = each.value.to_port
  ip_protocol                  = each.value.protocol
  cidr_ipv4                    = each.value.cidr_ipv4 != "" ? each.value.cidr_ipv4 : null
  referenced_security_group_id = each.value.referenced_security_group_name != "" ? aws_security_group.sg[each.value.referenced_security_group_name].id : null
}

resource "aws_vpc_security_group_egress_rule" "sg_egress_rule" {

  for_each = { for v in local.egress : "${v.security_group_name}_egress_${v.from_port}_${v.to_port}_${v.cidr_ipv4}_${v.referenced_security_group_name}" => v }

  security_group_id            = aws_security_group.sg[each.value.security_group_name].id
  from_port                    = each.value.from_port
  to_port                      = each.value.to_port
  ip_protocol                  = each.value.protocol
  cidr_ipv4                    = each.value.cidr_ipv4 != "" ? each.value.cidr_ipv4 : null
  referenced_security_group_id = each.value.referenced_security_group_name != "" ? aws_security_group.sg[each.value.referenced_security_group_name].id : null
}


