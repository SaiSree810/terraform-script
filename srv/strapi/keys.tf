
resource "aws_key_pair" "keys" {
  key_name   = "key1"
  public_key = file("${path.module}/./id_rsa.pub")
}