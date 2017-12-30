control "cis-aws-foundations-3.1" do
  title "Ensure a log metric filter and alarm exist for unauthorized API calls"
  desc  "Real-time monitoring of API calls can be achieved by directing
CloudTrail Logs to CloudWatch Logs and establishing corresponding metric
filters and alarms. It is recommended that a metric filter and alarm be
established for unauthorized API calls."
  impact 0.5
  tag "rationale": "Monitoring unauthorized API calls will help reveal
application errors and may reduce time to detect malicious activity."
  tag "cis_impact": "This alert may be triggered by normal read-only console
activities that attempt to opportunistically gather optional information, but
gracefully fail if they don't have permissions.

'If an excessive number of alerts are being generated then an organization may
wish to consider adding read access to the limited IAM user permissions simply
to quiet the alerts.

'In some cases doing this may allow the users to actually view some areas of
the system - any additional access given should be reviewed for alignment with
the original limited IAM user intent."
  tag "cis_rid": "3.1"
  tag "cis_level": 1
  tag "cis_control_number": ""
  tag "nist": ""
  tag "cce_id": "CCE-79186-3"
  tag "check": "Perform the following to determine if the account is configured
as prescribed:
1. Identify the log group name configured for use with CloudTrail:


'aws cloudtrail describe-trails
2. Note the <cloudtrail_log_group_name> value associated with
CloudWatchLogsLogGroupArn:


''arn:aws:logs:eu-west-1:<aws_account_number>:log-group:<cloudtrail_log_group_name>:*'

3. Get a list of all associated metric filters for this
<cloudtrail_log_group_name>:


'aws logs describe-metric-filters --log-group-name
'<cloudtrail_log_group_name>'4. Ensure the output from the above command
contains the following:


''filterPattern': '{ ($.errorCode = \\'*UnauthorizedOperation\\') ||
($.errorCode = \\'AccessDenied*\\') }'
5. Note the _<unauthorized_api_calls_metric>_ value associated with the
filterPattern found in step 4.
6. Get a list of CloudWatch alarms and filter on the
_<unauthorized_api_calls_metric>_ captured in step 5.


'aws cloudwatch describe-alarms --query
'MetricAlarms[?MetricName==`_<unauthorized_api_calls_metric>_`]'
7. Note the AlarmActions value - this will provide the SNS topic ARN value.
8. Ensure there is at least one subscriber to the SNS topic


'aws sns list-subscriptions-by-topic --topic-arn _<sns_topic_arn> _

"
  tag "fix": "Perform the following to setup the metric filter, alarm, SNS
topic, and subscription:
1. Create a metric filter based on filter pattern provided which checks for
unauthorized API calls and the <cloudtrail_log_group_name> taken from audit
step 2.


'aws logs put-metric-filter --log-group-name <cloudtrail_log_group_name>
--filter-name _<unauthorized_api_calls_metric>_ --metric-transformations
metricName=_<unauthorized_api_calls_metric>_,metricNamespace='CISBenchmark',metricValue=1
--filter-pattern '{ ($.errorCode = '*UnauthorizedOperation') || ($.errorCode =
'AccessDenied*') }'
NOTE: You can choose your own metricName and metricNamespace strings. Using the
same metricNamespace for all Foundations Benchmark metrics will group them
together.
2. Create an SNS topic that the alarm will notify


'aws sns create-topic --name _<sns_topic_name>_
NOTE: you can execute this command once and then re-use the same topic for all
monitoring alarms.
3. Create an SNS subscription to the topic created in step 2


'aws sns subscribe --topic-arn <sns_topic_arn> --protocol _<protocol_for_sns>_
--notification-endpoint _<sns_subscription_endpoints>_
NOTE: you can execute this command once and then re-use the SNS subscription
for all monitoring alarms.
4. Create an alarm that is associated with the CloudWatch Logs Metric Filter
created in step 1 and an SNS topic created in step 2


'aws cloudwatch put-metric-alarm --alarm-name
<_<em>unauthorized_api_calls__alarm></em> --metric-name
_<unauthorized_api_calls_metric>_ --statistic Sum --period 300 --threshold 1
--comparison-operator GreaterThanOrEqualToThreshold --evaluation-periods 1
--namespace 'CISBenchmark' --alarm-actions <sns_topic_arn>

NOTE: set the period and threshold to values that fit your organization.
"
end