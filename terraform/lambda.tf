resource "aws_lambda_function" "cloudwatch_to_slack" {
  function_name = "${var.prefix}-cloudwatch-alarm-to-slack"
  handler       = "main.lambda_handler"
  runtime       = var.runtime
  s3_bucket     = var.s3_bucket
  s3_key        = var.s3_key

  role = aws_iam_role.cloudwatch_to_slack_exec_role.arn

  environment {
    variables = {
      SLACK_WEBHOOK_URL = var.slack_webhook_url
    }
  }
}

resource "aws_lambda_permission" "allow_sns_to_call_cloudwatch_to_slack" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cloudwatch_to_slack.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.cloudwatch_alarm.arn
}

data "aws_iam_policy_document" "cloudwatch_to_slack_exec_role" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "cloudwatch_to_slack_exec_role" {
  name               = "${var.prefix}-cloudwatch-alarm-to-slack"
  assume_role_policy = data.aws_iam_policy_document.cloudwatch_to_slack_exec_role.json
}

resource "aws_iam_role_policy_attachment" "cloudwatch_to_slack_logging" {
  role       = aws_iam_role.cloudwatch_to_slack_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
