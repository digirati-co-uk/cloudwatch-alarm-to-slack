resource "aws_sns_topic" "cloudwatch_alarm" {
  name = "${var.prefix}-cloudwatch-alarm-slack"
}

resource "aws_sns_topic_subscription" "cloudwatch_to_slack_subscription" {
  topic_arn = aws_sns_topic.cloudwatch_alarm.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.cloudwatch_to_slack.arn
}

resource "aws_sns_topic_policy" "cloudwatch_alarm_publish_sns_topic" {
  arn = aws_sns_topic.cloudwatch_alarm.arn

  policy = data.aws_iam_policy_document.cloudwatch_alarm_publish_sns_topic_policy.json
}

data "aws_iam_policy_document" "cloudwatch_alarm_publish_sns_topic_policy" {

  statement {
    effect = "Allow"

    actions = [
      "SNS:Publish"
    ]

    principals {
      type        = "Service"
      identifiers = ["cloudwatch.amazonaws.com"]
    }

    resources = [
      aws_sns_topic.cloudwatch_alarm.arn,
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"

      values = [
        var.account_id,
      ]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"

      values = [
        "arn:aws:cloudwatch:${var.region}:${var.account_id}:alarm:*",
      ]
    }
  }
}
