locals {
  code_deploy_policies = [
    "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole",
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
