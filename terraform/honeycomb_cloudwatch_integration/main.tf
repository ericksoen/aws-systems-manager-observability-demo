resource "aws_iam_role" "honeycomb_cloudwatch_logs" {
  name = "honeycomb-cloudwatch-logs-lambda-role-ssm"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}
resource "aws_iam_role_policy" "lambda_log_policy" {
  name   = "lambda-logs-policy-ssm"
  role   = aws_iam_role.honeycomb_cloudwatch_logs.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:logs:*:*:*"
    }
  ]
}
EOF
}

resource "aws_lambda_function" "cloudwatch_logs" {
  s3_bucket     = "honeycomb-integrations-us-east-1"
  s3_key        = "agentless-integrations-for-aws/LATEST/ingest-handlers.zip"
  function_name = "honeycomb-cloudwatch-logs-integration-ssm"
  role          = aws_iam_role.honeycomb_cloudwatch_logs.arn
  handler       = "cloudwatch-handler"
  runtime       = "go1.x"
  memory_size   = "128"

  environment {
    variables = {
      ENVIRONMENT         = "development"
      PARSER_TYPE         = "json"
      HONEYCOMB_WRITE_KEY = var.honeycomb_write_key
      DATASET             = var.honeycomb_dataset_name
      SAMPLE_RATE         = "1"
      TIME_FIELD_FORMAT   = ""
      TIME_FIELD_NAME     = "startTime"
    }
  }
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cloudwatch_logs.arn
  principal     = "logs.amazonaws.com"
}

resource "aws_cloudwatch_log_group" "ssm_logs" {
  name = "ssm-logs"
}

resource "aws_cloudwatch_log_subscription_filter" "hc_logfilter" {
  name            = "powershell-log-subscription-filter"
  destination_arn = aws_lambda_function.cloudwatch_logs.arn
  log_group_name  = aws_cloudwatch_log_group.ssm_logs.name
  filter_pattern  = ""
}