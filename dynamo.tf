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


  ttl {
    attribute_name = "TimeToExist"
    enabled        = false
  }

  tags = {
    Name = "Message"
  }
}