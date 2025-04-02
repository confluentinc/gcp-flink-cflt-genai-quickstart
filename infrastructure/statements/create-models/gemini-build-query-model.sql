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

Generate an SQL query for the following request:

Database Schema:

CREATE TABLE `${gcp-project-id}.${bigquery-db}.visits`
(
  Notes STRING,
  VisitID STRING,
  PatientID STRING,
  Summary STRING,
  DoctorID STRING,
  VisitDate DATE
);

CREATE TABLE `${gcp-project-id}.${bigquery-db}.patients`
(
  ContactInfo STRING,
  LastName STRING,
  Gender STRING,
  DateOfBirth DATE,
  FirstName STRING,
  PatientID STRING
);

CREATE TABLE `${gcp-project-id}.${bigquery-db}.generatedsummaries`
(
  GeneratedDate DATE,
  EndDate DATE,
  StartDate DATE,
  SummaryText STRING,
  PatientID STRING,
  SummaryID STRING
);

CREATE TABLE `${gcp-project-id}.${bigquery-db}.medicalrecords`
(
  Details STRING,
  RecordType STRING,
  Date DATE,
  PatientID STRING,
  RecordID STRING
);

CREATE TABLE `${gcp-project-id}.${bigquery-db}.appointments`
(
  Reason STRING,
  AppointmentDate DATE,
  PatientID STRING,
  DoctorID STRING,
  AppointmentID STRING
);

CREATE TABLE `${gcp-project-id}.${bigquery-db}.medications`
(
  MedicationName STRING,
  Frequency STRING,
  DatePrescribed DATE,
  Dosage STRING,
  PatientID STRING,
  MedicationID STRING
);

CREATE TABLE `${gcp-project-id}.${bigquery-db}.doctors`
(
  ContactInfo STRING,
  LastName STRING,
  Specialty STRING,
  FirstName STRING,
  DoctorID STRING
);

CREATE TABLE `${gcp-project-id}.${bigquery-db}.symptoms`
(
  Severity INT64,
  DateReported DATE,
  PatientID STRING,
  SymptomDescription STRING,
  SymptomID STRING
);

Make sure to join the main table with all the tables providing details on the different foreign keys.
Fields ending with "ID" are foreign keys joining to other tables.

VisitID field joins to the visits table.
PatientID field joins to the patients table.
SummaryID field joins to the generatedsummaries table.
RecordID field joins to the medicalrecords table.
AppointmentID field joins to the appointments table.
MedicationID field joins to the medications table.
DoctorID field joins to the doctors table.
SymptomID field joins to the symptoms table.

Return only the SQL query without any explanation or formatting. Do not add "```" or "```sql" around the results.

</instructions>'
);
