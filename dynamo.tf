resource "aws_dynamodb_table" "Message" {
  name           = "Message"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "MessageId"

  attribute {
    name = "MessageId"
    type = "S"
  }

  tags = {
    Name = "Message"
  }
}