locals {
  code_deploy_policies = [
    "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole",
    "arn:aws:iam::aws:policy/AutoScalingFullAccess"
  ]
}

resource "aws_iam_role" "code_deploy_role" {
  name               = "code_deploy_role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.code_deploy_assume_role.json
}

data "aws_iam_policy_document" "code_deploy_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codedeploy.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy_attachment" "code_deploy_attachment" {

  for_each = toset(local.code_deploy_policies)

  role       = aws_iam_role.code_deploy_role.name
  policy_arn = each.value
}

resource "aws_iam_role_policy_attachment" "code_deploy_policy_attachment" {
  role       = aws_iam_role.code_deploy_role.name
  policy_arn = aws_iam_policy.auto_scaling_policy.arn
}

resource "aws_iam_policy" "auto_scaling_policy" {
  name        = "auto_scaling_policy"
  path        = "/"
  description = "Auto Scaling Policy"
  policy      = data.aws_iam_policy_document.auto_scaling_policy_document.json
}

data "aws_iam_policy_document" "auto_scaling_policy_document" {
  statement {
    effect = "Allow"

    actions = [
      "application-autoscaling:*",
      "autoscaling:*",
      "ec2-autoscaling:*",
      "ec2:*",
      "iam:PassRole",
    ]

    resources = ["*"]
  }
}
