import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystorePropertiesFile = rootProject.projectDir.resolve("key.properties")
val keystoreProperties = Properties().apply {
    if (keystorePropertiesFile.exists()) {
        try {
            load(FileInputStream(keystorePropertiesFile))
        } catch (e: Exception) {
            println("Warning: Could not load key.properties: ${e.message}")
        }
    }
}

android {
    namespace = "com.example.alslat_aalnabi"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.alslat_aalnabi"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        val alias = keystoreProperties.getProperty("keyAlias")
        val pword = keystoreProperties.getProperty("keyPassword")
        val spword = keystoreProperties.getProperty("storePassword")
        val sfilePath = keystoreProperties.getProperty("storeFile")
        val sfile = sfilePath?.let { file(it) }

        val isSigningValid = alias != null && pword != null && sfile != null && sfile.exists() && !sfilePath.contains("REPLACE_WITH")

        create("release") {
            if (isSigningValid) {
                keyAlias = alias
                keyPassword = pword
                storeFile = sfile
                storePassword = spword
            } else {
                // Fallback to debug if not valid
                keyAlias = signingConfigs.getByName("debug").keyAlias
                keyPassword = signingConfigs.getByName("debug").keyPassword
                storeFile = signingConfigs.getByName("debug").storeFile
                storePassword = signingConfigs.getByName("debug").storePassword
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4") 
}

flutter {
    source = "../.."
}
