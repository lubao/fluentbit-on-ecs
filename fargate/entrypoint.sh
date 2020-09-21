#echo ${ECS_CONTAINER_METADATA_URI_V4}
#whereis jq
#sed -i "s/log_stream_prefix .*/log_stream_prefix $(hostname)-/g" /fluent-bit/etc/fluent-bit.conf
#echo $TASK_ARN
#echo $ECS_CLUSTER
#sed -i "s/TASK_ARN/$TASK_ARN/g" /fluent-bit/etc/fluent-bit.conf
#TASK_ARN=`cat /tmp/task_meta | jq '.TaskARN' | cut -d'"' -f2`
#cat /fluent-bit/etc/fluent-bit.conf
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
