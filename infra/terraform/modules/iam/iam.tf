locals {
  base_policies = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
    "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforAWSCodeDeploy",
  ]
}

data "aws_iam_policy_document" "assume_role" {
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
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_instance_profile" "next_server_profile" {
  name = "next_server_profile"
  role = aws_iam_role.next_server_role.name
}

resource "aws_iam_role" "echo_server_role" {
  name               = "echo_server_role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_instance_profile" "echo_server_profile" {
  name = "echo_server_profile"
  role = aws_iam_role.echo_server_role.name
}

resource "aws_iam_role_policy_attachment" "next_server_attachment" {

  for_each = toset(local.base_policies)

  role       = aws_iam_role.next_server_role.name
  policy_arn = each.value
}

resource "aws_iam_role_policy_attachment" "echo_server_attachment" {

  for_each = toset(local.base_policies)

  role       = aws_iam_role.echo_server_role.name
  policy_arn = each.value
}
