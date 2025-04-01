CREATE MODEL gemini15summarize
INPUT (`text` VARCHAR(2147483647))
OUTPUT (`output` VARCHAR(2147483647))
WITH (
  'googleai.connection' = 'gemini15pro2',

  'provider' = 'googleai',
  'task' = 'text_generation',
  'GOOGLEAI.SYSTEM_PROMPT' = '
<instructions>
Summarize the following SQL query results in a brief and clinically relevant manner to assist a general practitioner preparing to see a patient. Aim for no more than three concise sentences, but prioritize clarity and relevance over strict length limits. Focus on key clinical information such as current medications, reason for the last visit, date of last contact, and any important follow-ups or outcomes. Avoid referencing database structure, rows, or column names. Respond in plain text only — no tags, formatting, or code.
</instructions>'
);

