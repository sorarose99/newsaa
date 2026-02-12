#!/usr/bin/env python3
import os
import re

root_dir = 'lib/features/quran'
pattern = re.compile(r'\bconst\s+Gap\(')

fixed_count = 0
for subdir, dirs, files in os.walk(root_dir):
    for file in files:
        if file.endswith('.dart'):
            file_path = os.path.join(subdir, file)
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                new_content = pattern.sub('Gap(', content)
                
                if new_content != content:
                    with open(file_path, 'w', encoding='utf-8') as f:
                        f.write(new_content)
                    fixed_count += 1
                    print(f"Fixed: {file_path}")
            except Exception as e:
                print(f"Error processing {file_path}: {e}")

print(f"\nTotal files fixed: {fixed_count}")
