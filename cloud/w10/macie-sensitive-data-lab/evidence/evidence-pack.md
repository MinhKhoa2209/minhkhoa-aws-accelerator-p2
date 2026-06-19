# Macie Sensitive Data Lab Evidence

Verified on: 2026-06-19
Region: `us-east-1`
AWS account: `058114477594`

## Deployed Resources

| Resource | Value |
| --- | --- |
| S3 bucket | `xbrain-macie-sensitive-data-058114477594` |
| Sample object | `sample-data/customer-records-fake.txt` |
| Macie job | `3665a2f29be9b79dc599e709fefa9b23` |
| EventBridge rule | `xbrain-macie-sensitive-data-findings` |
| SNS topic | `arn:aws:sns:us-east-1:058114477594:xbrain-macie-sensitive-data-alerts` |
| Notification email | `minhkhoaoik2209@gmail.com` |

## Macie Findings

Macie returned classification findings for the sample S3 object.

| Finding ID | Type | Severity | Object |
| --- | --- | --- | --- |
| `32b76ee923c5d594487d692f2be3a33d` | `SensitiveData:S3Object/Multiple` | High | `xbrain-macie-sensitive-data-058114477594/sample-data/customer-records-fake.txt` |
| `1b5038158e49ba750d3a1c85434d1b30` | `SensitiveData:S3Object/Multiple` | High | `xbrain-macie-sensitive-data-058114477594/sample-data/customer-records-fake.txt` |

Detected sensitive data types:

| Category | Type | Count |
| --- | --- | --- |
| `PERSONAL_INFORMATION` | `USA_SOCIAL_SECURITY_NUMBER` | 1 |
| `FINANCIAL_INFORMATION` | `CREDIT_CARD_NUMBER` | 1 |

## Alerting Pipeline

EventBridge rule target:

| Rule | Target |
| --- | --- |
| `xbrain-macie-sensitive-data-findings` | `arn:aws:sns:us-east-1:058114477594:xbrain-macie-sensitive-data-alerts` |

SNS topic policy allows `events.amazonaws.com` to publish to the topic.

## SNS Subscription State

Latest AWS check showed the Gmail endpoint in `Deleted` state:

| Endpoint | Protocol | Subscription state |
| --- | --- | --- |
| `minhkhoaoik2209@gmail.com` | `email` | `Deleted` |

Because the subscription is currently deleted, the Macie finding evidence is valid, but email delivery is not currently active.
