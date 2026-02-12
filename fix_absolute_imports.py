#!/usr/bin/env python3
import os
import re

root_dir = 'lib/features/quran'

# Patterns to fix
patterns = [
    (r"import\s+'/core/", "import 'package:alslat_aalnabi/features/quran/core/"),
    (r"import\s+'/database/", "import 'package:alslat_aalnabi/features/quran/database/"),
    (r"import\s+'/presentation/", "import 'package:alslat_aalnabi/features/quran/presentation/"),
    (r"export\s+'/core/", "export 'package:alslat_aalnabi/features/quran/core/"),
    (r"export\s+'/database/", "export 'package:alslat_aalnabi/features/quran/database/"),
    (r"export\s+'/presentation/", "export 'package:alslat_aalnabi/features/quran/presentation/"),
]

fixed_count = 0
for subdir, dirs, files in os.walk(root_dir):
    for file in files:
        if file.endswith('.dart'):
            file_path = os.path.join(subdir, file)
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                new_content = content
                for pattern, replacement in patterns:
                    new_content = re.sub(pattern, replacement, new_content)
                
                if new_content != content:
                    with open(file_path, 'w', encoding='utf-8') as f:
                        f.write(new_content)
                    fixed_count += 1
                    print(f"Fixed: {file_path}")
            except Exception as e:
                print(f"Error processing {file_path}: {e}")

print(f"\nTotal files fixed: {fixed_count}")
