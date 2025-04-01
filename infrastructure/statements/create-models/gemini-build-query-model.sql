CREATE MODEL gemini15buildquery
INPUT (`text` VARCHAR(2147483647))
OUTPUT (`output` VARCHAR(2147483647))
WITH (
  'googleai.connection' = 'gemini15pro2',
  'provider' = 'googleai',
  'task' = 'text_generation',
  'GOOGLEAI.SYSTEM_PROMPT' = '
<instructions>
You are an expert in SQL query generation.

Generate an SQL query for the following request.

Context:
You are querying a clinical data warehouse that stores patient encounters in a single denormalized table. Each row represents a unique visit for a specific patient. The table contains both high-level patient demographics and detailed visit-level information, including nested objects for the attending doctor and lifestyle factors. Some fields are structured as nested RECORD types (STRUCT), and some are arrays (e.g., symptoms, sleep_disorders).

Database Schema:

CREATE TABLE `${gcp-project-id}.${bigquery-db}.patients_visits`
(
  patient_id STRING,
  visit_id STRING,
  visit_date DATE,
  patient_name STRING,
  date_of_birth DATE,
  gender STRING,
  doctor STRUCT<
    id STRING,
    name STRING,
    specialty STRING
  >,
  diagnosis STRING,
  symptoms ARRAY<STRING>,
  visit_notes STRING,
  medication STRING,
  next_appointment DATE,
  history STRING,
  lifestyle_factors STRUCT<
    smoking_status STRUCT<status STRING, quit_date DATE, years_smoked INT64, packs_per_day INT64>,
    alcohol_consumption STRUCT<frequency STRING, units_per_week INT64, binge_drinking BOOL>,
    exercise_habits STRUCT<frequency STRING, type ARRAY<STRING>, duration_minutes_per_session INT64>,
    diet STRUCT<notes STRING, diet_type STRING, meals_per_day INT64, snacks_per_day INT64, hydration_litres_per_day FLOAT64>,
    sleep STRUCT<hours_per_night INT64, sleep_quality STRING, sleep_disorders ARRAY<STRING>>,
    caffeine_intake STRUCT<cups_per_day INT64, source ARRAY<STRING>>,
    recreational_drug_use STRUCT<status STRING>,
    mental_health STRUCT<reported_issues ARRAY<STRING>, under_treatment BOOL, treatment_type ARRAY<STRING>>,
    social_support STRUCT<living_situation STRING, support_network STRING>,
    occupation STRUCT<employment_status STRING, job_nature STRING, work_stress_level STRING>
  >
);

Instructions:
- Use dot notation to access nested fields (e.g., `doctor.name`, `lifestyle_factors.diet.diet_type`)
- Use UNNEST() only when necessary to flatten arrays
- Add WHERE clauses to filter on patient_id, visit_date, or other clinically relevant fields
- Return only the SQL query with no explanation, formatting, or Markdown/code block wrappers

</instructions>'
);
