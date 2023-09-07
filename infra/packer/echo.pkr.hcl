build {

  name = "echo"

  sources = [
    "source.amazon-ebs.basic-example"
  ]

  provisioner "shell" {
    inline = concat(
      local.base_inlines,
      local.ssm_agent_inlines,
      local.cloudwatch_inlines,
      local.codedeploy_inlines,
    )
  }
}