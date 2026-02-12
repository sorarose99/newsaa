
import os

pubspec_path = 'pubspec.yaml'

with open(pubspec_path, 'r') as f:
    content = f.read()

# Extract the flutter config section (assets, fonts) from the broken file
# It starts at '  uses-material-design: true'
split_marker = '  uses-material-design: true'
if split_marker not in content:
    print("Error: marker not found")
    exit(1)

# we want to keep the marker and everything after
flutter_config = split_marker + content.split(split_marker)[1]

# Define the correct top part
top_part = """name: alslat_aalnabi
description: "A new Flutter project."
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: ^3.9.2

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  intl: any
  
  cupertino_icons: ^1.0.8
  
  flutter_local_notifications: ^19.5.0
  timezone: ^0.10.1
  
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  path_provider: ^2.1.4
  path: ^1.9.0
  sqflite: ^2.3.3
  connectivity_plus: ^6.1.0
  
  supabase_flutter: ^2.10.3
  
  get: ^4.6.6
  provider: ^6.1.2
  
  shared_preferences: ^2.3.3
  audioplayers: ^6.1.0
  fl_chart: ^1.1.1
  
  google_fonts: ^6.3.3
  share_plus: ^12.0.1
  uuid: ^4.4.0
  file_picker: ^10.3.6
  video_player: ^2.10.1
  url_launcher: ^6.2.0
  webview_flutter: ^4.7.0
  youtube_explode_dart: ^2.2.0
  dio: ^5.5.0
  
  # Quran Dependencies
  drift: ^2.29.0
  drift_flutter: ^0.2.7
  get_storage: 2.1.1
  quran_library: 
    git:
      ref: main
      url: https://github.com/alheekmahlib/quran_library.git
  just_audio: ^0.10.5
  audio_service: ^0.18.18
  wakelock_plus: ^1.4.0
  lottie: ^3.3.2
  flutter_svg: ^2.2.2
  html: ^0.15.6

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
  hive_generator: ^2.0.1
  build_runner: ^2.4.13
  flutter_native_splash: ^2.4.0
  drift_dev: ^2.25.2

flutter:
"""

# Combine
final_content = top_part + flutter_config

with open(pubspec_path, 'w') as f:
    f.write(final_content)

print("Successfully fixed pubspec.yaml")
