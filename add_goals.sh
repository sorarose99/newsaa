#!/bin/bash

# Add goals getter to all remaining localization files

files=(
  "app_localizations_fr.dart"
  "app_localizations_id.dart"
  "app_localizations_sw.dart"
  "app_localizations_es.dart"
  "app_localizations_zh.dart"
  "app_localizations_tr.dart"
  "app_localizations_ur.dart"
  "app_localizations_ru.dart"
  "app_localizations_uk.dart"
)

cd /Users/macbook/Downloads/Prophet_Mohammed-main/lib/l10n

for file in "${files[@]}"; do
  # Remove the closing brace
  sed -i '' '$ d' "$file"
  
  # Add the goals getter and closing brace
  echo "" >> "$file"
  echo "  @override" >> "$file"
  echo "  String get goals => 'Goals';" >> "$file"
  echo "}" >> "$file"
  echo "" >> "$file"
done

echo "Done adding goals getter to all localization files"
