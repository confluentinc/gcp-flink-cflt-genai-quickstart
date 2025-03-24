CREATE MODEL gemini15summarize
INPUT (`text` VARCHAR(2147483647))
OUTPUT (`output` VARCHAR(2147483647))
WITH (
  'googleai.connection' = 'gemini15pro2',

  'provider' = 'googleai',
  'task' = 'text_generation',
  'GOOGLEAI.SYSTEM_PROMPT' = '
<instructions>
Summarize the following results of a SQL query in 3 sentences maximum. Use an informal style, like a conversation. Do not describe the rows or columns. **Do not include any tags (e.g. YAML, XML or JSON) in the response. Only provide plain text.**
</instructions>'
);
