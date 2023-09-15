import json
import os
import requests


def parse_message(alert_message):
    """Process message and extract relevant fields"""
    alert_data = dict()
    default_value = "unknown"

    alert_data["name"] = alert_message.get("AlarmName", default_value)
    alert_data["description"] = alert_message.get("AlarmDescription", default_value)
    alert_data["new_state"] = alert_message.get("NewStateValue", default_value)
    alert_data["old_state"] = alert_message.get("OldStateValue", default_value)
    alert_data["reason"] = alert_message.get("NewStateReason", default_value)
    alert_data["dimensions"] = json.dumps(alert_message.get("Trigger", {}).get("Dimensions", []))
    return alert_data


def raise_slack_notification(webhook_url, alert_data):
    """Raise slack notification"""
    emoji = "" if alert_data["new_state"] == "OK" else ":exclamation:"

    message = {
        "text": f"Cloudwatch alarm: {alert_data['name']} {emoji}",
        "blocks": [
            {
                "type": "header",
                "text": {
                    "type": "plain_text",
                    "text": f"Cloudwatch alarm: {alert_data['name']} {emoji}"
                }
            },
            {
                "type": "section",
                "text": {
                    "type": "mrkdwn",
                    "text": f"State moved from {alert_data['old_state']} to {alert_data['new_state']}"
                }
            },
            {
                "type": "section",
                "text": {
                    "type": "mrkdwn",
                    "text": f"Description: {alert_data['description']}"
                }
            },
            {
                "type": "section",
                "text": {
                    "type": "mrkdwn",
                    "text": f"Reason: _{alert_data['reason']}_"
                }
            },
            {
                "type": "section",
                "text": {
                    "type": "mrkdwn",
                    "text": f"Dimensions: {alert_data['dimensions']}"
                }
            }
        ]
    }

    if not webhook_url:
        print(f"slack_webhook_url not provided, cannot sent {json.dumps(message, indent=2)}")
        return

    res = requests.post(webhook_url, json=message)
    print(f"Raised slack notification, received {res.status_code}")


def lambda_handler(event, context):
    print(f"Received event: {json.dumps(event, indent=2)}")

    alert_message = json.loads(event["Records"][0]["Sns"]["Message"])

    alert_values = parse_message(alert_message)

    webhook_url = os.getenv("SLACK_WEBHOOK_URL")
    raise_slack_notification(webhook_url, alert_values)


if __name__ == "__main__":
    with open('sample.json') as json_file:
        data = json.load(json_file)
        lambda_handler(data, None)
