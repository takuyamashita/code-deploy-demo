resource "aws_s3_bucket" "gin_artifact" {
  bucket = "code-deploy-test-gin-artifact"
}

resource "aws_s3_bucket" "next_artifact" {
  bucket = "code-deploy-test-next-artifact"
}
