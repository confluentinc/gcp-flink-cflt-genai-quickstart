import json
from difflib import SequenceMatcher

def string_similarity(a, b):
    """Calculate string similarity ratio between two strings."""
    return SequenceMatcher(None, a.lower(), b.lower()).ratio()

def save_json_file(data, filename):
    """Save data to a JSON file."""
    with open(filename, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)

def update_visit_notes():
    """Update visit notes with image findings from matching diagnoses."""
    # Load the files
    patient_visits = json.load(open('patient_visits.json', 'r', encoding='utf-8'))
    matching_diagnoses = json.load(open('matching_diagnoses.json', 'r', encoding='utf-8'))
    
    # Create a lookup of image findings by diagnosis
    diagnosis_findings = []
    for record in matching_diagnoses:
        diagnosis = record.get('diagnosis', '')
        image_finding = record.get('image_finding', '')
        url = record.get('link', '')
        if 'pneumonia' in diagnosis.lower() and image_finding:
            diagnosis_findings.append({
                'diagnosis': diagnosis,
                'finding': image_finding,
                'url': url
            })
    
    # Update visit notes
    updated_count = 0
    for patient_id, visit in patient_visits.items():
        diagnosis = visit.get('diagnosis', '')
        history = visit.get('history', '')
        
        # Check if this is a pneumonia case
        if 'pneumonia' in diagnosis.lower() or 'pneumonia' in history.lower():
            # Find all relevant matches
            matches = []
            for finding in diagnosis_findings:
                # Check similarity with both diagnosis and history
                diagnosis_similarity = string_similarity(diagnosis.lower(), finding['diagnosis'].lower())
                history_similarity = string_similarity(history.lower(), finding['diagnosis'].lower())
                
                # Use the higher similarity score
                similarity = max(diagnosis_similarity, history_similarity)
                
                if similarity > 0.5:  # 50% similarity threshold
                    matches.append({
                        'finding': finding['finding'],
                        'url': finding['url'],
                        'similarity': similarity
                    })
            
            if matches:
                # Sort matches by similarity score
                matches.sort(key=lambda x: x['similarity'], reverse=True)
                
                # Create the visit notes as a nested object with multiple findings
                visit['visit_notes'] = {
                    'findings': matches[0]['finding'],  # Use the best match for findings
                    'X-Ray Links': [match['url'] for match in matches]  # Include all matching URLs
                }
                updated_count += 1
    
    # Save the updated patient visits
    save_json_file(patient_visits, 'patient_visits_updated.json')
    return updated_count 