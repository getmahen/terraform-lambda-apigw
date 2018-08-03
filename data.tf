data "aws_s3_bucket_object" "playground_pkg" {
  bucket = "mahi-lambdas"
  key = "playground.zip"
}