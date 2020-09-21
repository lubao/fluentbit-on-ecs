FROM amazon/aws-for-fluent-bit 
RUN yum -y install jq
COPY fluentbit.conf /fluent-bit/etc/fluent-bit.conf 
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
