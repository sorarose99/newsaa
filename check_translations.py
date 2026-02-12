import json
import os
from pathlib import Path

arb_dir = 'lib/l10n'
files = sorted([f for f in os.listdir(arb_dir) if f.startswith('app_') and f.endswith('.arb')])

translations = {}
for file in files:
    path = os.path.join(arb_dir, file)
    with open(path, 'r', encoding='utf-8') as f:
        data = json.load(f)
        lang = file.replace('app_', '').replace('.arb', '')
        translations[lang] = set(data.keys())

print('عدد الملفات:', len(files))
print('اللغات المتوفرة:', ', '.join(sorted(translations.keys())))
print()

# Get all keys
all_keys = set()
for lang, keys in translations.items():
    all_keys.update(keys)

print('إجمالي المفاتيح الفريدة:', len(all_keys))
print()

# Check for missing keys
print('التحقق من المفاتيح المفقودة:')
print('=' * 50)

missing_found = False
for lang in sorted(translations.keys()):
    missing = all_keys - translations[lang]
    if missing:
        missing_found = True
        print(f'لغة {lang}: مفاتيح مفقودة ({len(missing)})')
        for key in sorted(missing):
            print(f'  - {key}')
        print()

if not missing_found:
    print('✓ جميع اللغات كاملة - لا توجد مفاتيح مفقودة')
