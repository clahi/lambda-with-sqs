# resource "aws_iam_role" "lambdaRole" {
#   name = "lambdaRole"
#   assume_role_policy = jsonencode({
#     "Version" : "2012-10-17"
#     "Statement" : [
#       {
#         "Effect" : "Allow"
#         "Action" : [
#           "sts:AssumeRole"
#         ]
#         "Principal" : {
#           "Service" : [
#             "lambda.amazonaws.com"
#           ]
#         }
#       }
#     ]
#   })
# }

# resource "aws_iam_policy" "lambdaPolicy" {
#   name = "lambdaPolicy"
#   policy = jsonencode(
#   {
#   "Version": "2012-10-17",
#   "Statement": [{
#       "Effect": "Allow",
#       "Action": [
#         "logs:CreateLogGroup",
#         "logs:CreateLogStream",
#         "logs:PutLogEvents"
#       ],
#       "Resource": "arn:aws:logs:*:*:*"
#     },
#     {
#       "Action": [
#         "dynamodb:PutItem"
#       ],
#       "Effect": "Allow",
#       "Resource": aws_dynamodb_table.arn
#     },
#     {
#       "Action": [
#         "sqs:Describe*",
#         "sqs:Get*",
#         "sqs:List*",
#         "sqs:DeleteMessage",
#         "sqs:ReceiveMessage"
#       ],
#       "Effect": "Allow",
#       "Resource": aws_sqs_queue.arn
#     }
#   ]
# }
#   )
# }

# resource "aws_iam_policy_attachment" "lambdaRolePolicyAttachment" {
#   policy_arn = aws_iam_policy.lambdaPolicy.arn
#   roles      = [aws_iam_role.lambdaRole.name]
#   name       = "lambdaRolePolicyAttachment"
# }

# data "archive_file" "lambdaFile" {
#   type        = "zip"
#   source_dir  = "${path.module}/lambdaFunction"
#   output_path = "${path.module}/lambda.zip"
# }

# resource "aws_lambda_function" "SQSDynamoDB" {
#   role             = aws_iam_role.lambdaRole.arn
#   filename         = data.archive_file.lambdaFile.output_path
#   source_code_hash = data.archive_file.lambdaFile.output_base64sha256
#   function_name    = "SQSDynamoDB"
#   timeout          = 60
#   runtime          = "python3.7"
#   handler          = "lambda.lambda_handler"

#   environment {
#     variables = {
#       DEST_BUCKET = aws_s3_bucket.myDestiBucket.id
#     }
#   }
# }

# resource "aws_lambda_permission" "SQSDynamoDBPermission" {
#   statement_id  = "AllowExecutionFromS3Bucket"
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.SQSDynamoDB.function_name
#   principal     = "s3.amazonaws.com"
#   source_arn    = aws_s3_bucket.mySourceBucket.arn
# }

# resource "aws_s3_bucket_notification" "bucketNotification" {
#   bucket = aws_s3_bucket.mySourceBucket.id

#   lambda_function {
#     lambda_function_arn = aws_lambda_function.resizeImagesLambda.arn
#     events              = ["s3:ObjectCreated:*"]
#   }

#   depends_on = [aws_lambda_permission.resizeImagePermission]
# }