insert into
`generated_sql`
select
session_id,
output
from
`input_request`,
LATERAL TABLE(ML_PREDICT('gemini15buildquery', request))
where session_id is not null;

