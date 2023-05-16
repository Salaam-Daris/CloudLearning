provider "aws" {
  region = "ap-south-1"
}

resource "aws_iam_role" "lambda-role" {
  name = "ec2-stop-start-new"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "lambda-ec2-role"
  }
}

resource "aws_iam_policy" "lambda-policy" {
  name = "lambda-ec2-stop-start-new"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource" = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeRegions",
          "ec2:StartInstances",
          "ec2:StopInstances"
        ],
        "Resource" = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda-ec2-policy-attach" {
  role       = aws_iam_role.lambda-role.name
  policy_arn = aws_iam_policy.lambda-policy.arn
}

resource "aws_lambda_function" "ec2-stop-start" {
  filename      = "lambda.zip"
  function_name = "lambda"
  role          = aws_iam_role.lambda-role.arn
  handler       = "lambda.lambda_handler"

  source_code_hash = filebase64sha256("lambda.zip")

  runtime = "python3.7"
  timeout = 63
}

resource "aws_cloudwatch_event_rule" "ec2-stop-rule" {
  name                = "ec2-stop-rule"
  description         = "Trigger Stop Instance at 2:59pm  "
  schedule_expression = "cron(59 08 * * ? *)"
  # schedule_expression = "rate(2 minutes)"
}

resource "aws_cloudwatch_event_target" "lambda-stop-func" {
  rule      = aws_cloudwatch_event_rule.ec2-stop-rule.name
  target_id = "lambda-stop"
  arn       = aws_lambda_function.ec2-stop-start.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_stop" {
  statement_id  = "AllowExecutionFromCloudWatchStop"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ec2-stop-start.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.ec2-stop-rule.arn
}

# resource "aws_cloudwatch_event_rule" "ec2-start-rule" {
#   name                = "ec2-start-rule"
#   description         = "Trigger Start Instance at 1:55pm "
#   schedule_expression = "cron(55 08 * * ? *)"
#   # schedule_expression = "rate(5 minutes)"
# }

# resource "aws_cloudwatch_event_target" "lambda-start-func" {
#   rule      = aws_cloudwatch_event_rule.ec2-start-rule.name
#   target_id = "lambda-start"
#   arn       = aws_lambda_function.ec2-stop-start.arn
# }

# resource "aws_lambda_permission" "allow_cloudwatch_start" {
#   statement_id  = "AllowExecutionFromCloudWatchStart"
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.ec2-stop-start.function_name
#   principal     = "events.amazonaws.com"
#   source_arn    = aws_cloudwatch_event_rule.ec2-start-rule.arn
# }
