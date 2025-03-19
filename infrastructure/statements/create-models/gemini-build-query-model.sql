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

CREATE TABLE `csid-281116.doctors_practice.Visits`
(
  Notes STRING,
  VisitID STRING,
  PatientID STRING,
  Summary STRING,
  DoctorID STRING,
  VisitDate DATE
);

CREATE TABLE `csid-281116.doctors_practice.Patients`
(
  ContactInfo STRING,
  LastName STRING,
  Gender STRING,
  DateOfBirth DATE,
  FirstName STRING,
  PatientID STRING
);

CREATE TABLE `csid-281116.doctors_practice.GeneratedSummaries`
(
  GeneratedDate DATE,
  EndDate DATE,
  StartDate DATE,
  SummaryText STRING,
  PatientID STRING,
  SummaryID STRING
);

CREATE TABLE `csid-281116.doctors_practice.MedicalRecords`
(
  Details STRING,
  RecordType STRING,
  Date DATE,
  PatientID STRING,
  RecordID STRING
);

CREATE TABLE `csid-281116.doctors_practice.Appointments`
(
  Reason STRING,
  AppointmentDate DATE,
  PatientID STRING,
  DoctorID STRING,
  AppointmentID STRING
);

CREATE TABLE `csid-281116.doctors_practice.Medications`
(
  MedicationName STRING,
  Frequency STRING,
  DatePrescribed DATE,
  Dosage STRING,
  PatientID STRING,
  MedicationID STRING
);

CREATE TABLE `csid-281116.doctors_practice.Doctors`
(
  ContactInfo STRING,
  LastName STRING,
  Specialty STRING,
  FirstName STRING,
  DoctorID STRING
);

CREATE TABLE `csid-281116.doctors_practice.Symptoms`
(
  Severity INT64,
  DateReported DATE,
  PatientID STRING,
  SymptomDescription STRING,
  SymptomID STRING
);

Make sure to join the main table with all the tables providing details on the different foreign keys.
Fields ending with "ID" are foreign keys joining to other tables.

VisitID field joins to the Visits table.
PatientID field joins to the Patients table.
SummaryID field joins to the GeneratedSummaries table.
RecordID field joins to the MedicalRecords table.
AppointmentID field joins to the Appointments table.
MedicationID field joins to the Medications table.
DoctorID field joins to the Doctors table.
SymptomID field joins to the Symptoms table.

Return only the SQL query without any explanation or formatting. Do not add "```" or "```sql" around the results.

</instructions>'
);
