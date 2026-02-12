
import os

pubspec_path = 'pubspec.yaml'

with open(pubspec_path, 'r') as f:
    content = f.read()

# Split at flutter:
if 'flutter:' not in content:
    print("Error: flutter: section not found")
    exit(1)

pre_flutter = content.split('flutter:')[0]

# Define the new flutter section
flutter_section = """flutter:

  uses-material-design: true
  generate: true

  assets:
    - assets/images/
    - assets/audio/
    - assets/svg/
    - assets/icons/
    - assets/svg/surah_name/
    - assets/svg/hijri/
    - assets/svg/alwaqf/
    - assets/json/
    - assets/lottie/
    - assets/locales/
    - assets/json/azkar.json

  flutter_native_splash:
    color: "#FFFFFF"
    image: assets/images/Logo.png
    android_12:
      image: assets/images/Logo.png
      icon_background_color: "#FFFFFF"

  fonts:
    - family: Kitab
      fonts:
        - asset: assets/Fonts/kitab.ttf
    - family: Amiri
      fonts:
        - asset: assets/Fonts/amiri.ttf
    - family: uthmanic
      fonts:
        - asset: assets/fonts/UthmanTN1_Ver10.otf
    - family: uthmanic2
      fonts:
        - asset: assets/fonts/UthmanicHafs_V20.ttf
    - family: kufi
      fonts:
        - asset: assets/fonts/Kufam-Italic-VariableFont_wght.ttf
          style: italic
        - asset: assets/fonts/Kufam-VariableFont_wght.ttf
          weight: 500
        - asset: assets/fonts/Kufam-Regular.ttf
          weight: 100
    - family: naskh
      fonts:
        - asset: assets/fonts/NotoNaskhArabic-VariableFont_wght.ttf
    - family: ayahNumber
      fonts:
        - asset: assets/fonts/Uthmanic_NeoCOLORD-Regular.ttf
    - family: urdu
      fonts:
        - asset: assets/fonts/NotoNastaliqUrdu.ttf
    - family: bn
      fonts:
        - asset: assets/fonts/NotoSerifBengali.ttf
"""

# Add page fonts
for i in range(1, 605):
    font_entry = f"""
    - family: page{i}
      fonts:
        - asset: assets/fonts/quran_fonts/QCF4{str(i).zfill(3)}_X-Regular.woff
"""
    flutter_section += font_entry

with open(pubspec_path, 'w') as f:
    f.write(pre_flutter + flutter_section)

print("Successfully updated pubspec.yaml")
