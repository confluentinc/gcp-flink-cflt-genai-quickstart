import json
from difflib import SequenceMatcher

def string_similarity(a, b):
    """Calculate string similarity ratio between two strings."""
    return SequenceMatcher(None, a.lower(), b.lower()).ratio()

def load_json_file(filename):
    """Load and return JSON data from a file."""
    with open(filename, 'r', encoding='utf-8') as f:
        return json.load(f)

def save_json_file(data, filename):
    """Save data to a JSON file."""
    with open(filename, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)

def find_matching_records(diagnoses_data, eurorad_data, similarity_threshold=0.8):
    """Find records in eurorad_data that match specific diagnoses."""
    matching_records = []
    
    # Define the specific diagnoses we want to match
    target_diagnoses = [
        "Cryptogenic organising pneumonia",
        "COVID-19 pneumonia",
        "Churg-Strauss syndrome"
    ]
    
    # Check each record in eurorad_data
    for record_id, record in eurorad_data.items():
        # Check both diagnosis and history fields
        record_diagnosis = record.get('diagnosis', '').lower()
        record_history = record.get('history', '').lower()
        
        # Check for matches in both fields
        for diagnosis in target_diagnoses:
            diagnosis_lower = diagnosis.lower()
            
            # Check if diagnosis matches directly or is similar
            if (diagnosis_lower in record_diagnosis or 
                diagnosis_lower in record_history or
                string_similarity(diagnosis_lower, record_diagnosis) > similarity_threshold or
                string_similarity(diagnosis_lower, record_history) > similarity_threshold):
                
                # Create a cleaned version of the record
                cleaned_record = {
                    'title': record.get('title', ''),
                    'section': record.get('section', ''),
                    'diagnosis': record.get('diagnosis', ''),
                    'history': record.get('history', ''),
                    'image_finding': record.get('image_finding', ''),
                    'discussion': record.get('discussion', ''),
                    'differential_diagnosis': record.get('differential_diagnosis', ''),
                    'figures': record.get('figures', []),
                    'area_of_interest': record.get('area_of_interest', []),
                    'imaging_technique': record.get('imaging_technique', []),
                    'link': record.get('link', ''),
                    'time': record.get('time', '')
                }
                
                matching_records.append(cleaned_record)
                break
    
    return matching_records

def analyze_matches(matching_file: str = 'matching_diagnoses.json'):
    """Analyze and print statistics about the matches found."""
    try:
        with open(matching_file, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        # Count matches by section
        section_counts = {}
        # Count matches by diagnosis
        diagnosis_counts = {}
        # Count matches by area of interest
        area_counts = {}
        
        for record in data:  # Now data is a list, not a dict
            # Count sections
            section = record.get('section', 'Unknown')
            section_counts[section] = section_counts.get(section, 0) + 1
            
            # Count diagnoses
            diagnosis = record.get('diagnosis', 'Unknown')
            diagnosis_counts[diagnosis] = diagnosis_counts.get(diagnosis, 0) + 1
            
            # Count areas of interest
            areas = record.get('area_of_interest', [])
            for area in areas:
                area_counts[area] = area_counts.get(area, 0) + 1
        
        # Print summary
        print("=== Match Analysis ===")
        print(f"Total matches found: {len(data)}")
        
        print("Top 5 Sections:")
        for section, count in sorted(section_counts.items(), key=lambda x: x[1], reverse=True)[:5]:
            print(f"- {section}: {count} matches")
        
        print("Top 5 Diagnoses:")
        for diagnosis, count in sorted(diagnosis_counts.items(), key=lambda x: x[1], reverse=True)[:5]:
            print(f"- {diagnosis}: {count} matches")
        
        print("Top 5 Areas of Interest:")
        for area, count in sorted(area_counts.items(), key=lambda x: x[1], reverse=True)[:5]:
            print(f"- {area}: {count} matches")
        
        # Calculate and print match rate
        total_records = len(data)
        print(f"Match Rate: {total_records} records processed")
        
    except FileNotFoundError:
        print(f"Error: {matching_file} not found. Please run the matching process first.")
    except json.JSONDecodeError:
        print(f"Error: {matching_file} contains invalid JSON data.")
    except Exception as e:
        print(f"Error analyzing matches: {e}")

if __name__ == "__main__":
    try:
        # Load the required data
        diagnoses_data = load_json_file('diagnoses.json')
        eurorad_data = load_json_file('eurorad_metadata.json')
        
        # Find matching records
        matching_records = find_matching_records(diagnoses_data, eurorad_data)
        
        # Save the matches
        save_json_file(matching_records, 'matching_diagnoses.json')
        
        # Analyze the matches
        analyze_matches()
        
    except Exception as e:
        print(f"Error: {e}")
        print("Please ensure diagnoses.json and eurorad_metadata.json exist and contain valid JSON data.") 