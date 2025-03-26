insert into
`sql_request`
select
session_id,
output
from
`text_request`,
LATERAL TABLE(ML_PREDICT('gemini15buildquery', request))
where session_id is not null;

