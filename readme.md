# Cloudwatch Alarm to Slack

Basic AWS lambda function use to raise received notifications to Slack. 

Notification originates from Cloudwatch Alarm -> SNS -> Lambda

## Lambda

Expects `SLACK_WEBHOOK_URL` env var to raise notification, if not supplied it will print payload that would be sent to Slack.

Parses incoming SNS message and POSTs to above webhook url.

See `sample.json` for example data, this allows the `main.py` to be run locally.

See `package.sh` to build zip file with dependencies

## Terraform

Terraform creates:

* Lambda function
* SNS Topic
* SNS Topic subscription to Lambda
* SNS Topic policy to allow Cloudwatch Alarms to publish

### Variables

| Variable          | Description                                              | Default    |
| ----------------- | -------------------------------------------------------- | ---------- |
| s3_bucket         | S3 bucket containing cloudwatch-to-slack Lambda function |            |
| s3_key            | S3 key for cloudwatch-to-slack Lambda function           |            |
| sns_topic_arn     | ARN of topic that will trigger Lambda                    |            |
| prefix            | Prefix for services                                      |            |
| slack_webhook_url | Slack webhook URL to call                                |            |
| runtime           | Python runtime to use for lambda                         | python3.11 |

### Outputs

| Variable      | Description                                    |
| ------------- | ---------------------------------------------- |
| sns_topic_arn | ARN of SNS topic for handling Cloudwatch Alarm |