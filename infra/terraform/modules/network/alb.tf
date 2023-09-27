resource "aws_lb" "front_alb" {
  name               = "front-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg[local.front_alb_sg].id]
  subnets = compact([
    for k, v in local.subnets : v.public_ip ? aws_subnet.subnet[k].id : null
  ])

  enable_deletion_protection = false
}

resource "aws_lb_listener" "front_alb" {
  load_balancer_arn = aws_lb.front_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.next_server.arn
  }
}

resource "aws_lb_listener_rule" "echo_nlb" {
  listener_arn = aws_lb_listener.front_alb.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.echo_nlb.arn
  }

  condition {
    path_pattern {

      values = ["/api/*"]
    }
  }
}

resource "aws_lb_target_group" "echo_nlb" {
  name     = "echo-server"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id
  target_type = "ip"

  health_check {
    path                = "/api/message"
    port                = 80
    protocol            = "HTTP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 10
  }
}

resource "aws_lb_target_group" "next_server" {
  name     = "next-server"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id
  target_type = "instance"

  health_check {
    path                = "/"
    port                = 3000
    protocol            = "HTTP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 10
  }
}

///////////////////////////////////////////////////
// Internal NLB
///////////////////////////////////////////////////

resource "aws_lb" "echo_nlb" {
  name               = "echo-nlb"
  internal           = true
  load_balancer_type = "network"
  
  security_groups    = [aws_security_group.sg[local.echo_nlb_sg].id]

  dynamic "subnet_mapping" {
    for_each = compact([
      for k, v in local.subnets : v.public_ip ? null : k
    ])

    content {
      subnet_id = aws_subnet.subnet[subnet_mapping.value].id
      private_ipv4_address = replace(cidrsubnet(aws_subnet.subnet[subnet_mapping.value].cidr_block, 4, 1), "/.{3}$/", "")
    }
    
  }

  enable_deletion_protection = false
}

resource "aws_lb_listener" "echo_nlb" {
  load_balancer_arn = aws_lb.echo_nlb.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.echo_server.arn
  }
}

resource "aws_lb_target_group" "echo_server" {
  name     = "internal-echo-server"
  port     = 80
  protocol = "TCP"
  vpc_id   = aws_vpc.vpc.id

  health_check {
    port                = 80
    protocol            = "TCP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 10
  }
}

resource "aws_lb_target_group_attachment" "front_alb" {

  for_each = toset([for v in aws_lb.echo_nlb.subnet_mapping : v.private_ipv4_address])

  target_group_arn = aws_lb_target_group.echo_nlb.arn
  target_id        = each.value
  port             = 80
}
