resource "aws_s3_bucket" "echo_artifact" {
  bucket = "code-deploy-test-echo-artifact"
}

resource "aws_s3_bucket" "next_artifact" {
  bucket = "code-deploy-test-next-artifact"
}
