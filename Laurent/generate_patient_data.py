import json
from data_generators import generate_unique_patients, generate_doctors, generate_mock_data
from match_diagnoses import find_matching_records, save_json_file
from update_visit_notes import update_visit_notes
from constants import DIAGNOSIS_CATEGORIES
import os

def save_json_file(data, filename, newline_delimited=False):
    """Save data to a JSON file.
    
    Args:
        data: The data to save
        filename: The output filename
        newline_delimited: If True, saves as newline-delimited JSON (one object per line)
    """
    if newline_delimited:
        # For newline-delimited JSON, write each record on a new line
        with open(filename, 'w', encoding='utf-8') as f:
            for record in data:
                # Convert to string with proper formatting
                json_str = json.dumps(record, ensure_ascii=False)
                f.write(json_str + '\n')
    else:
        # For regular JSON files, use pretty printing
        with open(filename, 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=2, ensure_ascii=False)

def cleanup_intermediate_files():
    """Remove intermediate files that are no longer needed."""
    files_to_remove = [
        'doctors.json',
        'patients.json',
        'patient_visits.json',
        'matching_diagnoses.json',
        'patient_visits_updated.json'
    ]
    
    print("Cleaning up intermediate files...")
    for file in files_to_remove:
        if os.path.exists(file):
            os.remove(file)
            print(f"Removed {file}")
        else:
            print(f"{file} not found, skipping...")

def main():
    """Main orchestrator function to generate and process patient data."""
    try:
        print("Starting patient data generation process...")
        
        # Step 1: Generate doctors
        print("Step 1: Generating doctors...")
        doctors = generate_doctors()
        save_json_file(doctors, 'doctors.json')
        print(f"Generated {len(doctors)} doctors")
        
        # Step 2: Generate unique patients
        print("Step 2: Generating unique patients...")
        patients = generate_unique_patients(100)  # Generate 100 patients
        save_json_file(patients, 'patients.json')
        print(f"Generated {len(patients)} unique patients")
        
        # Step 3: Generate patient visits
        print("Step 3: Generating patient visits...")
        patient_visits = generate_mock_data(100, doctors, patients, DIAGNOSIS_CATEGORIES)
        save_json_file(patient_visits, 'patient_visits.json')
        print(f"Generated {len(patient_visits)} patient visits")
        
        # Step 4: Load diagnoses and find matches
        print("Step 4: Finding matching diagnoses...")
        diagnoses_data = json.load(open('diagnoses.json', 'r', encoding='utf-8'))
        eurorad_data = json.load(open('eurorad_metadata.json', 'r', encoding='utf-8'))
        matching_records = find_matching_records(diagnoses_data, eurorad_data)
        save_json_file(matching_records, 'matching_diagnoses.json')
        print(f"Found {len(matching_records)} matching records")
        
        # Step 5: Update visit notes with image findings
        print("Step 5: Updating visit notes with image findings...")
        updated_count = update_visit_notes()
        print(f"Updated {updated_count} visit notes with image findings")
        
        # Step 6: Convert to newline-delimited JSON for BigQuery
        print("Step 6: Converting to BigQuery format...")
        if os.path.exists('patient_visits_updated.json'):
            # Load the updated visits
            with open('patient_visits_updated.json', 'r', encoding='utf-8') as f:
                visits_data = json.load(f)
            
            # Convert to list of records
            records = []
            for visit_id, visit in visits_data.items():
                visit['visit_id'] = visit_id  # Add visit_id to the record
                records.append(visit)
            
            # Save as newline-delimited JSON
            save_json_file(records, 'greenacres_gp_patients.json', newline_delimited=True)
            print("Saved data in BigQuery format")
        
        # Step 7: Clean up intermediate files
        cleanup_intermediate_files()
        
        print("Patient data generation process completed successfully!")
        print("Final output saved to greenacres_gp_patients.json")
        
    except Exception as e:
        print(f"Error during data generation process: {e}")
        raise

if __name__ == "__main__":
    main() 