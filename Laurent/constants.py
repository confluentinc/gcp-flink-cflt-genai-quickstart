# Sample data for random generation
BLOOD_TYPES = ["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"]

# Lifestyle factors options
SMOKING_STATUSES = ["Never smoker", "Former smoker", "Current smoker"]
ALCOHOL_FREQUENCIES = ["Never", "Rarely", "1-2 times per week", "2-3 times per week", "3-4 times per week", "Daily"]
EXERCISE_FREQUENCIES = ["Never", "Occasional", "1-2 times per week", "3-4 times per week", "Daily"]
EXERCISE_TYPES = ["Walking", "Running", "Swimming", "Cycling", "Yoga", "Gym", "Team sports", "Dancing"]
DIET_TYPES = ["Omnivore", "Vegetarian", "Vegan", "Pescatarian", "Keto", "Paleo", "Mediterranean"]
SLEEP_QUALITIES = ["Good", "Fair", "Poor", "Interrupted", "Very poor"]
SLEEP_DISORDERS = ["None", "Insomnia", "Sleep apnea", "Restless leg syndrome", "Narcolepsy"]
MENTAL_HEALTH_ISSUES = ["None", "Anxiety", "Depression", "Bipolar disorder", "PTSD", "OCD"]
TREATMENT_TYPES = ["None", "Therapy", "Medication", "Both", "Alternative medicine"]
LIVING_SITUATIONS = ["Lives alone", "With partner", "With family", "With roommates", "In assisted living"]
SUPPORT_NETWORKS = ["Strong", "Moderate", "Limited", "Very limited"]
EMPLOYMENT_STATUSES = ["Employed full-time", "Employed part-time", "Self-employed", "Unemployed", "Retired"]
JOB_NATURES = ["Sedentary (office work)", "Light physical", "Moderate physical", "Heavy physical", "Mixed"]
STRESS_LEVELS = ["Low", "Moderate", "High", "Very high"]

# Default lifestyle factors template
DEFAULT_LIFESTYLE_FACTORS = {
    "smoking_status": {
        "status": "Never smoker",
        "quit_date": None,
        "years_smoked": 0,
        "packs_per_day": 0
    },
    "alcohol_consumption": {
        "frequency": "Never",
        "units_per_week": 0,
        "binge_drinking": False
    },
    "exercise_habits": {
        "frequency": "Occasional",
        "type": ["Walking"],
        "duration_minutes_per_session": 30
    },
    "diet": {
        "notes": "Balanced diet",
        "diet_type": "Omnivore",
        "meals_per_day": 3,
        "snacks_per_day": 2,
        "hydration_litres_per_day": 2.0
    },
    "sleep": {
        "hours_per_night": 7,
        "sleep_quality": "Good",
        "sleep_disorders": ["None"]
    },
    "caffeine_intake": {
        "cups_per_day": 2,
        "source": ["Coffee"]
    },
    "recreational_drug_use": {
        "status": "Never used"
    },
    "mental_health": {
        "reported_issues": ["None"],
        "under_treatment": False,
        "treatment_type": ["None"]
    },
    "social_support": {
        "living_situation": "With family",
        "support_network": "Moderate"
    },
    "occupation": {
        "employment_status": "Employed full-time",
        "job_nature": "Sedentary (office work)",
        "work_stress_level": "Moderate"
    }
}

ALLERGIES = [
    "Penicillin",
    "Peanuts",
    "Shellfish",
    "Latex",
    "Aspirin",
    "Ibuprofen",
    "Eggs",
    "Milk",
    "Tree nuts",
    "Sulfa drugs",
    "Bee stings",
    "Gluten",
    "Soy",
    "Cats",
    "Mold",
    "Dust mites",
    "NSAIDs",
    "Contrast dye",
    "Nickel",
    "Codeine"
]

SYMPTOMS = [
    "Fever and cough",
    "Headache and dizziness",
    "Stomach pain",
    "Back pain",
    "Sore throat",
    "Chest pain",
    "Fatigue",
    "Joint pain",
    "Shortness of breath",
    "Rash"
]

DIAGNOSES = [
    "Common cold",
    "Hypertension",
    "Type 2 Diabetes",
    "Bronchitis",
    "Migraine",
    "Gastritis",
    "Arthritis",
    "Anxiety",
    "Asthma",
    "Allergic reaction"
]

MEDICATIONS = [
    "Amoxicillin",
    "Ibuprofen",
    "Paracetamol",
    "Metformin",
    "Lisinopril",
    "Ventolin",
    "Omeprazole",
    "Cetirizine",
    "Amlodipine",
    "Sertraline"
]

# Medical specialties
SPECIALTIES = [
    "Cardiology",
    "Neurology",
    "Pediatrics",
    "Orthopedics",
    "Dermatology",
    "Psychiatry",
    "Internal Medicine",
    "Emergency Medicine",
    "Family Medicine",
    "Ophthalmology"
]

# Comprehensive list of diagnoses with categories
DIAGNOSIS_CATEGORIES = {
    "Cardiovascular": [
        {
            "code": "I10",
            "name": "Essential (primary) hypertension",
            "description": "High blood pressure without a known cause",
            "symptoms": ["Headache", "Dizziness", "Chest pain", "Shortness of breath"]
        },
        {
            "code": "I21",
            "name": "Acute myocardial infarction",
            "description": "Heart attack",
            "symptoms": ["Chest pain", "Shortness of breath", "Nausea", "Sweating"]
        },
        {
            "code": "I48",
            "name": "Atrial fibrillation",
            "description": "Irregular and often rapid heart rate",
            "symptoms": ["Palpitations", "Fatigue", "Shortness of breath", "Chest pain"]
        }
    ],
    "Respiratory": [
        {
            "code": "J45",
            "name": "Asthma",
            "description": "Chronic respiratory condition causing airway inflammation",
            "symptoms": ["Wheezing", "Shortness of breath", "Coughing", "Chest tightness"]
        },
        {
            "code": "J20",
            "name": "Acute bronchitis",
            "description": "Inflammation of the bronchial tubes",
            "symptoms": ["Cough", "Mucus production", "Fatigue", "Shortness of breath"]
        },
        {
            "code": "J18",
            "name": "Pneumonia",
            "description": "Infection that inflames air sacs in lungs",
            "symptoms": ["Cough with phlegm", "Fever", "Difficulty breathing", "Chest pain"]
        }
    ],
    "Endocrine": [
        {
            "code": "E11",
            "name": "Type 2 diabetes mellitus",
            "description": "Chronic condition affecting blood sugar regulation",
            "symptoms": ["Increased thirst", "Frequent urination", "Fatigue", "Blurred vision"]
        },
        {
            "code": "E05",
            "name": "Hyperthyroidism",
            "description": "Overactive thyroid gland",
            "symptoms": ["Weight loss", "Rapid heartbeat", "Anxiety", "Tremors"]
        }
    ],
    "Neurological": [
        {
            "code": "G43",
            "name": "Migraine",
            "description": "Severe headache with associated symptoms",
            "symptoms": ["Severe headache", "Nausea", "Sensitivity to light", "Aura"]
        },
        {
            "code": "G40",
            "name": "Epilepsy",
            "description": "Neurological disorder causing seizures",
            "symptoms": ["Seizures", "Loss of consciousness", "Unusual sensations", "Confusion"]
        }
    ],
    "Musculoskeletal": [
        {
            "code": "M15",
            "name": "Osteoarthritis",
            "description": "Degenerative joint disease",
            "symptoms": ["Joint pain", "Stiffness", "Swelling", "Reduced range of motion"]
        },
        {
            "code": "M54",
            "name": "Low back pain",
            "description": "Pain in the lower back region",
            "symptoms": ["Back pain", "Muscle stiffness", "Limited mobility", "Pain with movement"]
        }
    ],
    "Mental Health": [
        {
            "code": "F41",
            "name": "Anxiety disorder",
            "description": "Excessive worry and fear",
            "symptoms": ["Excessive worry", "Restlessness", "Rapid heartbeat", "Difficulty concentrating"]
        },
        {
            "code": "F32",
            "name": "Major depressive disorder",
            "description": "Persistent feelings of sadness and loss of interest",
            "symptoms": ["Depressed mood", "Loss of interest", "Sleep problems", "Fatigue"]
        }
    ],
    "Gastrointestinal": [
        {
            "code": "K29",
            "name": "Gastritis",
            "description": "Inflammation of the stomach lining",
            "symptoms": ["Stomach pain", "Nausea", "Vomiting", "Loss of appetite"]
        },
        {
            "code": "K80",
            "name": "Cholelithiasis",
            "description": "Gallstones",
            "symptoms": ["Upper right abdominal pain", "Nausea", "Vomiting", "Back pain"]
        }
    ],
    "Dermatological": [
        {
            "code": "L20",
            "name": "Atopic dermatitis",
            "description": "Chronic skin condition causing inflammation",
            "symptoms": ["Itchy skin", "Redness", "Dry skin", "Rashes"]
        },
        {
            "code": "L40",
            "name": "Psoriasis",
            "description": "Autoimmune condition affecting the skin",
            "symptoms": ["Red patches", "Scaling", "Itching", "Joint pain"]
        }
    ]
}

# Diagnosis medications mapping
DIAGNOSIS_MEDICATIONS = {
    "Cardiovascular": {
        "Essential (primary) hypertension": ["Lisinopril", "Amlodipine", "Metoprolol"],
        "Acute myocardial infarction": ["Aspirin", "Nitroglycerin", "Metoprolol"],
        "Atrial fibrillation": ["Warfarin", "Diltiazem", "Amiodarone"]
    },
    "Respiratory": {
        "Asthma": ["Albuterol", "Fluticasone", "Montelukast"],
        "Acute bronchitis": ["Azithromycin", "Guaifenesin", "Dextromethorphan"],
        "Pneumonia": ["Amoxicillin", "Azithromycin", "Levofloxacin"]
    },
    "Endocrine": {
        "Type 2 diabetes mellitus": ["Metformin", "Glimepiride", "Insulin glargine"],
        "Hyperthyroidism": ["Methimazole", "Propylthiouracil", "Propranolol"]
    },
    "Neurological": {
        "Migraine": ["Sumatriptan", "Propranolol", "Amitriptyline"],
        "Epilepsy": ["Levetiracetam", "Lamotrigine", "Valproic acid"]
    },
    "Musculoskeletal": {
        "Osteoarthritis": ["Ibuprofen", "Acetaminophen", "Meloxicam"],
        "Low back pain": ["Diclofenac", "Cyclobenzaprine", "Gabapentin"]
    },
    "Mental Health": {
        "Anxiety disorder": ["Sertraline", "Buspirone", "Alprazolam"],
        "Major depressive disorder": ["Fluoxetine", "Sertraline", "Venlafaxine"]
    },
    "Gastrointestinal": {
        "Gastritis": ["Omeprazole", "Ranitidine", "Sucralfate"],
        "Cholelithiasis": ["Ursodiol", "Ketorolac", "Ondansetron"]
    },
    "Dermatological": {
        "Atopic dermatitis": ["Hydrocortisone", "Tacrolimus", "Cetirizine"],
        "Psoriasis": ["Methotrexate", "Adalimumab", "Calcipotriene"]
    }
} 