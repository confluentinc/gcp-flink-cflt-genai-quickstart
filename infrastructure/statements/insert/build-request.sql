insert into
`generated_sql`
select
sessionId,
output
from
`input_request`,
LATERAL TABLE(ML_PREDICT('gemini15buildquery', request))
where sessionId is not null;

