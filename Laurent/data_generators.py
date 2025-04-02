import random
from datetime import datetime, timedelta
import uuid
from faker import Faker
from constants import (
    BLOOD_TYPES, ALLERGIES, SPECIALTIES, DIAGNOSIS_CATEGORIES,
    DIAGNOSIS_MEDICATIONS, DEFAULT_LIFESTYLE_FACTORS, SMOKING_STATUSES,
    ALCOHOL_FREQUENCIES, EXERCISE_FREQUENCIES, EXERCISE_TYPES,
    DIET_TYPES, SLEEP_QUALITIES, SLEEP_DISORDERS, MENTAL_HEALTH_ISSUES,
    TREATMENT_TYPES, LIVING_SITUATIONS, SUPPORT_NETWORKS,
    EMPLOYMENT_STATUSES, JOB_NATURES, STRESS_LEVELS
)

# Initialize Faker
fake = Faker()

def generate_random_date(start_date, end_date):
    """Generate a random date between start_date and end_date."""
    time_between = end_date - start_date
    days_between = time_between.days
    random_days = random.randint(0, days_between)
    random_date = start_date + timedelta(days=random_days)
    return random_date.strftime("%Y-%m-%d")

def generate_patient_details():
    """Generate basic patient details including name and contact information."""
    # Generate gender first
    gender = random.choice(["M", "F", "Other"])
    
    # Generate name based on gender
    if gender == "F":
        first_name = fake.first_name_female()
    elif gender == "M":
        first_name = fake.first_name_male()
    else:
        first_name = fake.first_name()
    
    last_name = fake.last_name()
    
    # Generate personalized email based on name
    email_format = random.choice([
        f"{first_name.lower()}{random.randint(1, 999)}@gmail.com",
        f"{first_name.lower()}.{last_name.lower()}@gmail.com",
        f"{first_name[0].lower()}{last_name.lower()}{random.randint(1, 99)}@gmail.com",
        f"{first_name.lower()}{last_name[0].lower()}{random.randint(1, 999)}@gmail.com"
    ])
    
    return {
        "first_name": first_name,
        "last_name": last_name,
        "gender": gender,
        "email": email_format,
        "phone": fake.phone_number(),
        "address": fake.address()
    }

def generate_doctors():
    """Generate a dictionary of doctors with their details and specialties."""
    doctors = {}
    
    for _ in range(10):
        # Generate gender first
        gender = random.choice(["M", "F", "Other"])
        
        # Generate name based on gender
        if gender == "F":
            first_name = fake.first_name_female()
        elif gender == "M":
            first_name = fake.first_name_male()
        else:
            first_name = fake.first_name()
        
        last_name = fake.last_name()
        
        # Generate doctor details
        doctor_id = str(uuid.uuid4())
        specialty = random.choice(SPECIALTIES)
        years_experience = random.randint(5, 30)
        
        doctor = {
            "doctor_id": doctor_id,
            "first_name": first_name,
            "last_name": last_name,
            "full_name": f"Dr. {first_name} {last_name}",
            "gender": gender,
            "specialty": specialty,
            "years_experience": years_experience,
            "email": f"dr_{first_name.lower()}_{last_name.lower()}@greenacres.ie",
            "phone": fake.phone_number(),
            "office_location": fake.address(),
            "education": [
                {
                    "degree": "MD",
                    "institution": fake.company(),
                    "year": fake.year()
                },
                {
                    "degree": "Residency",
                    "institution": fake.company(),
                    "year": fake.year()
                }
            ],
            "certifications": [
                f"Board Certified in {specialty}",
                "Basic Life Support (BLS)",
                "Advanced Cardiac Life Support (ACLS)"
            ],
            "languages": random.sample(["English", "Spanish", "French", "German", "Mandarin"], random.randint(1, 3)),
            "availability": {
                "monday": "9:00 AM - 5:00 PM",
                "tuesday": "9:00 AM - 5:00 PM",
                "wednesday": "9:00 AM - 5:00 PM",
                "thursday": "9:00 AM - 5:00 PM",
                "friday": "9:00 AM - 5:00 PM",
                "saturday": "Closed",
                "sunday": "Closed"
            }
        }
        doctors[doctor_id] = doctor
    
    return doctors

def generate_unique_patients(num_patients):
    """Generate a dictionary of unique patients with their details."""
    patients = {}
    used_names = set()  # To ensure unique names
    
    while len(patients) < num_patients:
        # Generate patient details
        patient_details = generate_patient_details()
        full_name = f"{patient_details['first_name']} {patient_details['last_name']}"
        
        # Skip if name is already used
        if full_name in used_names:
            continue
            
        used_names.add(full_name)
        patient_id = str(uuid.uuid4())
        
        # Generate random number of allergies (0-5)
        num_allergies = random.randint(0, 5)
        patient_allergies = random.sample(ALLERGIES, num_allergies) if num_allergies > 0 else None
        
        patient = {
            "patient_id": patient_id,
            "first_name": patient_details['first_name'],
            "last_name": patient_details['last_name'],
            "full_name": full_name,
            "gender": patient_details['gender'],
            "date_of_birth": generate_random_date(datetime(1950, 1, 1), datetime(2000, 12, 31)),
            "blood_type": random.choice(BLOOD_TYPES),
            "height_cm": round(random.uniform(150, 190), 1),
            "weight_kg": round(random.uniform(50, 100), 1),
            "email": patient_details['email'],
            "phone": patient_details['phone'],
            "address": patient_details['address'],
            "allergies": patient_allergies,
            "lifestyle_factors": generate_lifestyle_factors(),
            "medical_history": {
                "chronic_conditions": random.sample(["None", "Hypertension", "Asthma", "Diabetes", "Arthritis"], random.randint(0, 2)),
                "previous_surgeries": random.sample(["None", "Appendectomy", "Knee Surgery", "Dental Surgery"], random.randint(0, 2))
            },
            "emergency_contact": {
                "name": fake.name(),
                "relationship": random.choice(["Spouse", "Parent", "Sibling", "Friend"]),
                "phone": fake.phone_number()
            }
        }
        patients[patient_id] = patient
    
    return patients

def get_visit_data(diagnosis):
    """Generate realistic visit data for a given diagnosis using predefined patterns."""
    category = next(cat for cat, diags in DIAGNOSIS_CATEGORIES.items() if diagnosis in diags)
    
    # Get appropriate medications for this diagnosis
    medications = DIAGNOSIS_MEDICATIONS.get(category, {}).get(diagnosis['name'], ["Standard treatment medication"])
    
    # Generate a realistic visit note based on the diagnosis
    symptoms = random.sample(diagnosis['symptoms'], min(2, len(diagnosis['symptoms'])))
    visit_notes = f"Patient presented with {', '.join(symptoms)}. "
    
    if category == "Cardiovascular":
        visit_notes += f"Vital signs and physical examination consistent with {diagnosis['name']}. "
    elif category == "Respiratory":
        visit_notes += f"Respiratory examination and chest auscultation findings support {diagnosis['name']}. "
    elif category == "Endocrine":
        visit_notes += f"Clinical presentation and lab results indicate {diagnosis['name']}. "
    elif category == "Neurological":
        visit_notes += f"Neurological examination and patient history confirm {diagnosis['name']}. "
    elif category == "Musculoskeletal":
        visit_notes += f"Physical examination and imaging studies suggest {diagnosis['name']}. "
    elif category == "Mental Health":
        visit_notes += f"Clinical assessment and patient history support {diagnosis['name']}. "
    elif category == "Gastrointestinal":
        visit_notes += f"Abdominal examination and symptoms consistent with {diagnosis['name']}. "
    else:  # Dermatological
        visit_notes += f"Physical examination and skin findings confirm {diagnosis['name']}. "
    
    visit_notes += "Treatment plan discussed and follow-up scheduled."
    
    return {
        "symptoms": symptoms,
        "visit_notes": visit_notes,
        "medication": random.choice(medications)
    }

def get_random_diagnosis(diagnosis_categories):
    """Get a random diagnosis from the categories."""
    category = random.choice(list(diagnosis_categories.keys()))
    diagnosis = random.choice(diagnosis_categories[category])
    return diagnosis

def generate_mock_data(num_patients, doctors, patients, diagnoses):
    """Generate mock medical visit records with multiple visits per patient."""
    start_date = datetime(2023, 1, 1)
    end_date = datetime(2024, 3, 1)
    
    # Use all doctors
    doctor_ids = list(doctors.keys())
    
    # Use all patients
    patient_ids = list(patients.keys())
    
    records = {}
    total_records = 0
    target_records = 2000  # Target total number of records
    
    while total_records < target_records:
        # Select a random patient
        patient_id = random.choice(patient_ids)
        patient = patients[patient_id]
        
        # Generate random number of visits for this patient (3-15)
        num_visits = random.randint(3, 15)
        
        # Generate visits for this patient
        for _ in range(num_visits):
            visit_date = generate_random_date(start_date, end_date)
            next_appointment = generate_random_date(
                datetime.strptime(visit_date, "%Y-%m-%d"),
                datetime.strptime(visit_date, "%Y-%m-%d") + timedelta(days=90)
            )
            
            # Select a random doctor
            doctor_id = random.choice(doctor_ids)
            doctor = doctors[doctor_id]
            
            # Get a random diagnosis and generate realistic visit data
            diagnosis = get_random_diagnosis(diagnoses)
            visit_data = get_visit_data(diagnosis)
            
            visit_id = str(uuid.uuid4())
            records[visit_id] = {
                "patient_id": patient_id,
                "visit_id": visit_id,
                "visit_date": visit_date,
                "patient_name": patient['full_name'],
                "date_of_birth": patient['date_of_birth'],
                "gender": patient['gender'],
                "doctor": {
                    "id": doctor_id,
                    "name": doctor['full_name'],
                    "specialty": doctor['specialty']
                },
                "diagnosis": diagnosis['name'],
                "symptoms": visit_data['symptoms'],
                "visit_notes": visit_data['visit_notes'],
                "medication": visit_data['medication'],
                "next_appointment": next_appointment,
                "history": f"Patient presented with {', '.join(visit_data['symptoms'])}. Previous medical history includes {', '.join(patient['medical_history']['chronic_conditions'])}.",
                "lifestyle_factors": patient['lifestyle_factors']
            }
            total_records += 1
            
            # Break if we've reached our target
            if total_records >= target_records:
                break
        
        # Break if we've reached our target
        if total_records >= target_records:
            break
    
    return records

def generate_lifestyle_factors():
    """Generate random lifestyle factors for a patient."""
    smoking_status = random.choice(SMOKING_STATUSES)
    quit_date = None
    years_smoked = 0
    packs_per_day = 0
    
    if smoking_status == "Former smoker":
        quit_date = generate_random_date(datetime(2010, 1, 1), datetime(2023, 12, 31))
        years_smoked = random.randint(1, 20)
        packs_per_day = random.randint(1, 3)
    elif smoking_status == "Current smoker":
        years_smoked = random.randint(1, 30)
        packs_per_day = random.randint(1, 3)
    
    alcohol_frequency = random.choice(ALCOHOL_FREQUENCIES)
    units_per_week = 0
    if alcohol_frequency != "Never":
        units_per_week = random.randint(1, 30)
    
    exercise_frequency = random.choice(EXERCISE_FREQUENCIES)
    exercise_types = []
    if exercise_frequency != "Never":
        exercise_types = random.sample(EXERCISE_TYPES, random.randint(1, 3))
    
    diet_type = random.choice(DIET_TYPES)
    diet_notes = random.choice([
        "Balanced diet",
        "High salt intake, low fruit/veg",
        "High protein, low carb",
        "Regular balanced meals",
        "Irregular eating patterns"
    ])
    
    sleep_quality = random.choice(SLEEP_QUALITIES)
    sleep_disorders = ["None"]
    if sleep_quality in ["Poor", "Interrupted", "Very poor"]:
        sleep_disorders = random.sample(SLEEP_DISORDERS, random.randint(1, 2))
    
    mental_health_issues = ["None"]
    under_treatment = False
    treatment_type = ["None"]
    if random.random() < 0.3:  # 30% chance of having mental health issues
        mental_health_issues = random.sample(MENTAL_HEALTH_ISSUES, random.randint(1, 2))
        if "None" not in mental_health_issues:
            under_treatment = random.choice([True, False])
            if under_treatment:
                treatment_type = random.sample(TREATMENT_TYPES, random.randint(1, 2))
    
    return {
        "smoking_status": {
            "status": smoking_status,
            "quit_date": quit_date,
            "years_smoked": years_smoked,
            "packs_per_day": packs_per_day
        },
        "alcohol_consumption": {
            "frequency": alcohol_frequency,
            "units_per_week": units_per_week,
            "binge_drinking": random.choice([True, False]) if alcohol_frequency != "Never" else False
        },
        "exercise_habits": {
            "frequency": exercise_frequency,
            "type": exercise_types,
            "duration_minutes_per_session": random.randint(15, 120) if exercise_frequency != "Never" else 0
        },
        "diet": {
            "notes": diet_notes,
            "diet_type": diet_type,
            "meals_per_day": random.randint(1, 5),
            "snacks_per_day": random.randint(0, 5),
            "hydration_litres_per_day": round(random.uniform(1.0, 3.0), 1)
        },
        "sleep": {
            "hours_per_night": random.randint(4, 10),
            "sleep_quality": sleep_quality,
            "sleep_disorders": sleep_disorders
        },
        "caffeine_intake": {
            "cups_per_day": random.randint(0, 6),
            "source": random.sample(["Coffee", "Tea", "Energy drinks"], random.randint(1, 3))
        },
        "recreational_drug_use": {
            "status": random.choice(["Never used", "Former user", "Occasional user", "Regular user"])
        },
        "mental_health": {
            "reported_issues": mental_health_issues,
            "under_treatment": under_treatment,
            "treatment_type": treatment_type
        },
        "social_support": {
            "living_situation": random.choice(LIVING_SITUATIONS),
            "support_network": random.choice(SUPPORT_NETWORKS)
        },
        "occupation": {
            "employment_status": random.choice(EMPLOYMENT_STATUSES),
            "job_nature": random.choice(JOB_NATURES),
            "work_stress_level": random.choice(STRESS_LEVELS)
        }
    } 