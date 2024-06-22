terraform {
  backend "s3" {
    bucket = "pramod858tf"
    key    = "path/to/my/key"
    region = "us-east-1"
  }
}
