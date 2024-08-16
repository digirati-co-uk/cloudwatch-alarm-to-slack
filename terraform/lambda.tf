resource "aws_lambda_function" "cloudwatch_to_slack" {
  function_name = "${var.prefix}-cloudwatch-alarm-to-slack"
  description   = "Sends message to Slack, based on SNS notification originating from Cloudwatch alarm"
  handler       = "main.lambda_handler"
  runtime       = var.runtime
  s3_bucket     = var.s3_bucket
  s3_key        = var.s3_key

  layers = var.slack_webhook_secret != "" ? ["arn:aws:lambda:eu-west-1:015030872274:layer:AWS-Parameters-and-Secrets-Lambda-Extension:11"] : []

  role = aws_iam_role.cloudwatch_to_slack_exec_role.arn

  environment {
    variables = local.env_vars
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

data "aws_iam_policy_document" "cloudwatch_to_slack_read_secrets" {
  statement {
    actions = [
      "secretsmanager:GetSecretValue"
    ]

    resources = [
      "arn:aws:secretsmanager:${var.region}:${var.account_id}:secret:${var.slack_webhook_secret}*"
    ]
  }
}

resource "aws_iam_role_policy" "cloudwatch_to_slack_read_secrets" {
  count = var.slack_webhook_secret == "" ? 0 : 1

  name   = "${var.prefix}-cloudwatch-alarm-to-slack-secrets"
  role   = aws_iam_role.cloudwatch_to_slack_exec_role.name
  policy = data.aws_iam_policy_document.cloudwatch_to_slack_read_secrets.json
}
