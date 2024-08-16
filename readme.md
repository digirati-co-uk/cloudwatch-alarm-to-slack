# Cloudwatch Alarm to Slack

Basic AWS lambda function use to raise received notifications to Slack. 

Notification originates from Cloudwatch Alarm -> SNS -> Lambda

## Lambda

Expects either `SLACK_WEBHOOK_URL` or `SLACK_WEBHOOK_SECRET` env var to raise notifications:

* `SLACK_WEBHOOK_URL` - Webook URL value
* `SLACK_WEBHOOK_SECRET` - AWS SecretsManager Id containing webook URL as plain text.

If not supplied it will print payload that would be sent to Slack. If both supplied `SLACK_WEBHOOK_URL` takes precedence.

Parses incoming SNS message and POSTs to above webhook url.

See `sample.json` for example data, this allows the `main.py` to be run locally.

See `package.sh` to build zip file with dependencies

## Terraform

Terraform creates:

* Lambda function
* SNS Topic
* SNS Topic subscription to Lambda
* SNS Topic policy to allow Cloudwatch Alarms to publish
* if `SLACK_WEBHOOK_SECRET` provided:
  * `AWS Parameters and Secrets Lambda Extension` layer is added
  * Permissions for Lambda execution policy to read secret

### Variables

| Variable             | Description                                                            | Default    |
| -------------------- | ---------------------------------------------------------------------- | ---------- |
| s3_bucket            | S3 bucket containing cloudwatch-to-slack Lambda function               |            |
| s3_key               | S3 key for cloudwatch-to-slack Lambda function                         |            |
| sns_topic_arn        | ARN of topic that will trigger Lambda                                  |            |
| prefix               | Prefix for services                                                    |            |
| slack_webhook_url    | Slack webhook URL to call (optional)                                   |            |
| slack_webhook_secret | AWS SecretsManager secret storing Slack webhook URL to call (optional) |            |
| runtime              | Python runtime to use for lambda                                       | python3.11 |

### Outputs

| Variable      | Description                                    |
| ------------- | ---------------------------------------------- |
| sns_topic_arn | ARN of SNS topic for handling Cloudwatch Alarm |