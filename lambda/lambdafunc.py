import json
import boto3
import logging
import time

def lambda_handler(event, context):
    
    # Initialize CloudWatch client in ap-south-1 region
    cloudwatch = boto3.client('cloudwatch', region_name='ap-south-1')
    
    # Send a custom metric to CloudWatch
    metric_name = 'MyMetric'
    metric_value = 1
    metric_unit = 'Count'
    metric_namespace = 'MyNamespace'
    response = cloudwatch.put_metric_data(
        MetricData=[
            {
                'MetricName': metric_name,
                'Dimensions': [
                    {
                        'Name': 'InstanceID',
                        'Value': 'i-1234567890abcdef0'
                    },
                ],
                'Value': metric_value,
                'Unit': metric_unit
            },
        ],
        Namespace=metric_namespace
    )
    
    # Create a CloudWatch alarm for the metric
    alarm_name = 'MyAlarm'
    alarm_description = 'Alarm for my custom metric'
    alarm_actions = ['arn:aws:sns:ap-south-1:123456789012:my-sns-topic']
    threshold = 2
    evaluation_periods = 1
    period = 60
    comparison_operator = 'GreaterThanOrEqualToThreshold'
    response = cloudwatch.put_metric_alarm(
        AlarmName=alarm_name,
        AlarmDescription=alarm_description,
        ActionsEnabled=True,
        AlarmActions=alarm_actions,
        MetricName=metric_name,
        Namespace=metric_namespace,
        Statistic='Average',
        Dimensions=[
            {
                'Name': 'InstanceID',
                'Value': 'i-1234567890abcdef0'
            },
        ],
        Period=period,
        EvaluationPeriods=evaluation_periods,
        Threshold=threshold,
        ComparisonOperator=comparison_operator
    )
    
    # Send a log message to CloudWatch
    log_group_name = 'my_log_group'
    log_stream_name = 'my_log_stream'
    log_message = 'Hello, CloudWatch!'
    logging.basicConfig(format='%(levelname)s:%(message)s', level=logging.INFO)
    logging.info(log_message)
    cloudwatch_logs = boto3.client('logs', region_name='ap-south-1')
    response = cloudwatch_logs.create_log_stream(
        logGroupName=log_group_name,
        logStreamName=log_stream_name
    )
    response = cloudwatch_logs.put_log_events(
        logGroupName=log_group_name,
        logStreamName=log_stream_name,
        logEvents=[
            {
                'timestamp': int(round(time.time() * 1000)),
                'message': log_message
            },
        ]
    )
    
    return {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda!')
    }
