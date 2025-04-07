insert into
`summarised_results`
select
sessionId,
output
from
`sql_results`,
LATERAL TABLE(ML_PREDICT('gemini15summarize', results))
where sessionId is not null;

