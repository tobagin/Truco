
import os
import glob
import sys

def update_gresource():
    gresource_path = 'data/io.github.tobagin.Truco.gresource.xml.in'
    
    # Read existing
    with open(gresource_path, 'r') as f:
        existing_lines = f.readlines()
        
    # Clean out old card definitions to avoiding duplicates if we run multiple times
    # We want to keep avatars, sounds, ui, backs
    # We want to remove 'cards/modern/' and 'cards/spanish/' and old 'cards/'
    
    cleaned_lines = []
    for line in existing_lines:
        line_strip = line.strip()
        # Keep <gresource ...>, <file alias=...> usually sounds/ui
        # Remove lines that are just <file>cards/...</file> UNLESS it is backs
        
        is_card = '<file>cards/' in line
        is_back = 'backs/' in line
        
        # If it is a card and NOT a back, we filter it out to regenerate cleanly
        if is_card and not is_back:
            continue
            
        cleaned_lines.append(line)
        
    # Find insertion point (before </gresource>)
    insert_idx = -1
    for i, line in enumerate(cleaned_lines):
        if '</gresource>' in line:
            insert_idx = i
            break
            
    if insert_idx == -1:
        print("Error: Could not find </gresource> tag")
        sys.exit(1)
        
    # Collect new files
    new_files = []
    
    # Modern
    modern_files = sorted(glob.glob('data/cards/modern/*.svg'))
    for p in modern_files:
        rel = p.replace('data/', '')
        new_files.append(f'    <file>{rel}</file>\n')
        
    # Spanish
    spanish_files = sorted(glob.glob('data/cards/spanish/*.svg'))
    for p in spanish_files:
        rel = p.replace('data/', '')
        new_files.append(f'    <file>{rel}</file>\n')
        
    print(f"Adding {len(new_files)} card files to gresource.")
    
    # Insert
    final_lines = cleaned_lines[:insert_idx] + new_files + cleaned_lines[insert_idx:]
    
    with open(gresource_path, 'w') as f:
        f.writelines(final_lines)
        
if __name__ == "__main__":
    update_gresource()
