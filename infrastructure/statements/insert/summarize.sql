insert into
`summarised_results`
select
session_id,
output
from
`sql_results`,
LATERAL TABLE(ML_PREDICT('gemini15summarize', results))
where session_id is not null;

