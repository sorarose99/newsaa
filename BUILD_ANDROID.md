# Android Build Instructions

This document provides instructions for building and verifying the Android application for the Prophet Mohammed Admin Panel.

## Prerequisites

1.  **Flutter SDK**: Ensure Flutter is installed and configured.
2.  **Android SDK**: Ensure Android Studio and the Android SDK are installed.
3.  **App Credentials**: The app is pre-configured with the Supabase project `orpgzkvovcaywvugddei`.

## Build Steps

Run the following command in the project root directory:

```bash
flutter build apk --release
```

The APK will be generated at the following path:
`build/app/outputs/flutter-apk/app-release.apk`

## Verification Checklist

Once the APK is installed on your Android device:

1.  **Admin Login**: Log in to the admin panel.
2.  **Virtues Management**:
    - Upload a **Video File** from your device's gallery/storage.
    - Verify that the upload is successful and the video can be previewed.
3.  **Prayer Formula Sounds**:
    - Upload an **Audio File** from your device.
    - Test the "Play" button to verify the audio plays correctly before saving.
    - Save and verify the sound appears in the list.

## Why it's Optimized

- **Path-Based Uploads**: Unlike the Web version which loads entire files into RAM, the Android version streams files directly from the storage path to Supabase. This ensures that even large 100MB+ videos won't crash the app.
- **Media Permissions**: The app is pre-configured with the necessary permissions to access images, videos, and audio on modern Android versions (including Android 13+ granularity).
