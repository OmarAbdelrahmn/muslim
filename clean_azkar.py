import re
import os

file_path = r'c:\Users\omarf\OneDrive\Desktop\FlutterApp\PrayerApp\flutter_application_1\lib\azkar_page.dart'

with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Pattern to match AzkarItem text and reference
# We look for text: '...' and reference: '...'
def clean_dots(match):
    full_text = match.group(0)
    
    # Clean text property
    text_match = re.search(r"text:\s*'([^']*)'", full_text)
    if text_match:
        text_val = text_match.group(1).strip()
        if text_val.endswith('.'):
            # Remove trailing dot, but watch out for space-dot or multiple dots
            cleaned_text = re.sub(r'\s*\.+\s*$', '', text_val)
            full_text = full_text.replace(f"text: '{text_val}'", f"text: '{cleaned_text}'")
            
    # Clean reference property
    ref_match = re.search(r"reference:\s*'([^']*)'", full_text)
    if ref_match:
        ref_val = ref_match.group(1).strip()
        if ref_val.endswith('.'):
            cleaned_ref = re.sub(r'\s*\.+\s*$', '', ref_val)
            full_text = full_text.replace(f"reference: '{ref_val}'", f"reference: '{cleaned_ref}'")
            
    return full_text

# Regex to find AzkarItem definitions
# Handling potential multiple lines and properties
new_content = re.sub(r"AzkarItem\s*\((?:.|\n)*?\)", clean_dots, content)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(new_content)

print("Cleanup completed successfully.")
