locals {
  ec2_base_policies = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
    "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforAWSCodeDeploy",
  ]
}

resource "aws_iam_policy" "code_deploy_policy" {
  name        = "code_deploy_policy"
  path        = "/"
  description = "Code Deploy Policy"
  policy      = data.aws_iam_policy_document.code_deploy_policy_document.json
}

data "aws_iam_policy_document" "code_deploy_policy_document" {
  statement {
    effect = "Allow"

    actions = [
      "codedeploy-commands-secure:GetDeploymentSpecification",
      "codedeploy-commands-secure:PollHostCommand",
      "codedeploy-commands-secure:PutHostCommandAcknowledgement",
      "codedeploy-commands-secure:PutHostCommandComplete",
    ]

    resources = ["*"]
  }
}

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "next_server_role" {
  name               = "next_server_role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

resource "aws_iam_instance_profile" "next_server_profile" {
  name = "next_server_profile"
  role = aws_iam_role.next_server_role.name
}

resource "aws_iam_role" "echo_server_role" {
  name               = "echo_server_role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

resource "aws_iam_instance_profile" "echo_server_profile" {
  name = "echo_server_profile"
  role = aws_iam_role.echo_server_role.name
}

resource "aws_iam_role_policy_attachment" "next_server_attachment" {

  for_each = toset(local.ec2_base_policies)

  role       = aws_iam_role.next_server_role.name
  policy_arn = each.value
}

resource "aws_iam_role_policy_attachment" "echo_server_attachment" {

  for_each = toset(local.ec2_base_policies)

  role       = aws_iam_role.echo_server_role.name
  policy_arn = each.value
}

resource "aws_iam_role_policy_attachment" "next_server_code_deploy_attachment" {
  role       = aws_iam_role.next_server_role.name
  policy_arn = aws_iam_policy.code_deploy_policy.arn
}

resource "aws_iam_role_policy_attachment" "echo_server_code_deploy_attachment" {
  role       = aws_iam_role.echo_server_role.name
  policy_arn = aws_iam_policy.code_deploy_policy.arn
}

