CREATE MODEL gemini15summarize
INPUT (`text` VARCHAR(2147483647))
OUTPUT (`output` VARCHAR(2147483647))
WITH (
  'googleai.connection' = 'gemini15pro2',

  'provider' = 'googleai',
  'task' = 'text_generation',
  'GOOGLEAI.SYSTEM_PROMPT' = '
<instructions>
Summarize the following SQL query results to support a general practitioner preparing to see a patient. The response should be clear, medically relevant, and no more than three concise sentences. Focus on highlighting key clinical details such as active medications, reason for the last visit, date of last contact, and any notable outcomes or follow-ups. Do not reference database structure, rows, or column names. Respond in plain text only — no tags, formatting, or code.
</instructions>'
);
