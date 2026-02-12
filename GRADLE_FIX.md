# Gradle Build Error - Java 25 Compatibility Issue

## Problem
The Gradle build fails with: `java.lang.IllegalArgumentException: 25.0.1`

This occurs because **Java 25** is too new for the current Gradle/Kotlin toolchain.

## Solution

### Option 1: Install Java 21 LTS (Recommended)
1. Download Java 21 LTS from: https://www.oracle.com/java/technologies/downloads/
2. Install it to a separate directory (e.g., `C:\Program Files\Java\jdk-21`)
3. Set `JAVA_HOME` environment variable to point to Java 21:
   ```
   set JAVA_HOME=C:\Program Files\Java\jdk-21
   ```
4. Run: `gradlew clean`

### Option 2: Downgrade Java 25 to Java 21
If you don't need Java 25, uninstall it and install Java 21 LTS instead.

### Option 3: Build Environment Variable
Set this before running gradlew:
```batch
set JAVA_HOME=C:\path\to\java21
```

## Why This Happens
- Kotlin 2.1.x's JavaVersion parser doesn't recognize Java 25's version string format
- Gradle 8.14.1 only guarantees support up to Java 24
- Future Gradle versions (9.0+) will fully support Java 25

## Current Configuration
- **Gradle**: 8.14.1
- **Kotlin**: 2.1.20
- **Java**: 25.0.1 (incompatible)
- **Target Java**: 11

## Files Modified
- `android/gradle.properties`: Added compatibility settings
- `android/settings.gradle.kts`: Updated Kotlin to 2.1.20
- `android/gradle/wrapper/gradle-wrapper.properties`: Updated to Gradle 8.14.1
