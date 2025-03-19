insert into
`results_summarized`
select
session_id,
output
from
`raw_results`,
LATERAL TABLE(ML_PREDICT('gemini15summarize', results))
where session_id is not null;

