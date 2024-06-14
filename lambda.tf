resource "aws_iam_role" "lambdaRole" {
  name = "lambdaRole"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17"
    "Statement" : [
      {
        "Effect" : "Allow"
        "Action" : [
          "sts:AssumeRole"
        ]
        "Principal" : {
          "Service" : [
            "lambda.amazonaws.com"
          ]
        }
      }
    ]
  })
}

resource "aws_iam_policy" "lambdaPolicy" {
  name = "lambdaPolicy"
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [{
        "Effect" : "Allow",
        "Action" : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource" : "arn:aws:logs:*:*:*"
        },
        {
          "Action" : [
            "dynamodb:PutItem"
          ],
          "Effect" : "Allow",
          "Resource" : "${aws_dynamodb_table.Message.arn}"
        },
        {
          "Action" : [
            "sqs:Describe*",
            "sqs:Get*",
            "sqs:List*",
            "sqs:DeleteMessage",
            "sqs:ReceiveMessage"
          ],
          "Effect" : "Allow",
          "Resource" : "${aws_sqs_queue.Messages.arn}"
        }
      ]
    }
  )
}

resource "aws_iam_policy_attachment" "lambdaRolePolicyAttachment" {
  policy_arn = aws_iam_policy.lambdaPolicy.arn
  roles      = [aws_iam_role.lambdaRole.name]
  name       = "lambdaRolePolicyAttachment"
}

data "archive_file" "lambdaFile" {
  type        = "zip"
  source_file  = "${path.module}/lambda.py"
  output_path = "${path.module}/lambda.zip"
}

resource "aws_lambda_function" "SQSDynamoDB" {
  role             = aws_iam_role.lambdaRole.arn
  filename         = data.archive_file.lambdaFile.output_path
  source_code_hash = data.archive_file.lambdaFile.output_base64sha256
  function_name    = "SQSDynamoDB"
  runtime          = "python3.9"
  handler          = "lambda.lambda_handler"

  environment {
    variables = {
      QUEUE_NAME         = "Messages"
      MAX_QUEUE_MESSAGES = 10
      DYNAMODB_TABLE     = "Message"
    }
  }
}

resource "aws_lambda_permission" "SQSDynamoDBPermission" {
  statement_id  = "AllowExecutionFromSQS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.SQSDynamoDB.function_name
  principal     = "sqs.amazonaws.com"
}

resource "aws_lambda_event_source_mapping" "sqsTrigger" {
  batch_size       = 10
  event_source_arn = aws_sqs_queue.Messages.arn
  enabled          = true
  function_name    = aws_lambda_function.SQSDynamoDB.arn
}