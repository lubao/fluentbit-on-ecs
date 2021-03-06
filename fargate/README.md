# FluentBit to CloudWatch and Firehose

## Create Kinesis Firehose Delivery Stream to S3

Please reference our [official document](https://docs.aws.amazon.com/firehose/latest/dev/create-destination.html) to create a firehose delivery stream to S3.

## Sample fluentBit configuration file. 

* Please **MODIFIED** parameters in _***ITALIC and UNDERLINED***_ accordingly,

```
[INPUT]
    Name tail
    Path $PATH_TO_DEBUG_LOG
    Tag debug-log
    DB $PATH_TO_DEBUG_LOG_FILE_DB
    
[INPUT]
    Name tail
    Path $PATH_TO_DEBUG_LOG
    Tag error-log
    DB $PATH_TO_DEBUG_LOG_FILE_DB

[FILTER]
    Name record_modifier
    Match *
    Record ecs_cluster ECS_CLUSTER
    Record ecs_task_definition TASK_DEFINITION
    Record ecs_task_id TASK_ID
    
[OUTPUT]
    Name cloudwatch
    Match error-log
    region $CLOUDWATCH_REGION
    log_group_name $CLOUDWATCH_LOG_GROUP_NAME
    log_stream_prefix TASK_ID-
    auto_create_group true

[OUTPUT]
    Name firehose
    Match debug-log
    region $FIREHOSE_REGION
    delivery_stream $DELIVERY_STREAM
```

## Sample entrypoint.sh

```
echo -n "AWS for Fluent Bit Container Image Version "
cat /AWS_FOR_FLUENT_BIT_VERSION
curl -s ${ECS_CONTAINER_METADATA_URI_V4}/task > /tmp/task_meta
cat /tmp/task_meta | jq '.'
TASK_ID=`cat /tmp/task_meta | jq '.TaskARN' | cut -d'"' -f2 | cut -d'/' -f2`
ECS_CLUSTER=`cat /tmp/task_meta | jq '.Cluster' | cut -d'"' -f2 | cut -d'/' -f2`
FAMILY=`cat /tmp/task_meta | jq '.Family' | cut -d'"' -f2`
REV=`cat /tmp/task_meta | jq '.Revision' | cut -d'"' -f2`
sed -i "s/TASK_ID/$TASK_ID/g" /fluent-bit/etc/fluent-bit.conf
sed -i "s/TASK_DEFINITION/$FAMILY:$REV/g" /fluent-bit/etc/fluent-bit.conf
sed -i "s/ECS_CLUSTER/$ECS_CLUSTER/g" /fluent-bit/etc/fluent-bit.conf
exec /fluent-bit/bin/fluent-bit -e /fluent-bit/firehose.so -e /fluent-bit/cloudwatch.so -e /fluent-bit/kinesis.so -c /fluent-bit/etc/fluent-bit.conf
```

## Sample Dockerfile

```
FROM amazon/aws-for-fluent-bit 
COPY fluentbit.conf /fluent-bit/etc/fluent-bit.conf 
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
```

## Sample Log

```
root@ip-172-31-11-174:~# mkdir /var/log/nginx
root@ip-172-31-11-174:~# mkdir /var/log/app
root@ip-172-31-11-174:~# echo '[ERROR] Error Info' > /var/log/nginx/nginx.log
root@ip-172-31-11-174:~# echo '[DEBUG] Debug Info' > /var/log/app/app.log
```

### CloudWatch Error Log

[Image: Screen Shot 2020-09-21 at 10.54.28.png]
### S3 Debug Log

[Image: Screen Shot 2020-09-21 at 10.59.54.png]
# Note

* The configuration only **WORK** on **Fargate 1.4** and above.
* [Source code of fluent-bit](https://github.com/fluent/fluent-bit) 
* [Source code of amazon-kinesis-streams-for-fluent-bit](https://github.com/aws/amazon-kinesis-streams-for-fluent-bit) 
* The log format will in **JSON** format as showed below,

```
{
    "ecs_cluster": "ECS_CLUSTER_NAME",
    "ecs_task_definition": "TASK_NAME:TASK_REV",
    "ecs_task_id": "TASK_ID",
    "log":“Your Log Message”
}
```

