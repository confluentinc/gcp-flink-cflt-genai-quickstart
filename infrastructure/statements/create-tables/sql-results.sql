CREATE TABLE
sql_results (
session_id STRING PRIMARY KEY NOT ENFORCED,
results STRING
) DISTRIBUTED INTO 1 BUCKETS
WITH
(
'changelog.mode' = 'append',
'kafka.cleanup-policy' = 'compact',
'value.fields-include' = 'all',
'key.format' = 'json-registry',
'value.format' = 'json-registry',
'kafka.consumer.isolation-level' = 'read-uncommitted'
);
