resource "aws_cloudwatch_log_group" "gin_log" {
  name = "gin.log"

  skip_destroy = false

  retention_in_days = 1
}