plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.flutter_application_1"

    // Required by flutter_local_notifications 21.0.0.
    compileSdk = 36

    ndkVersion = flutter.ndkVersion

    compileOptions {
        // Required by flutter_local_notifications.
        isCoreLibraryDesugaringEnabled = true

        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.flutter_application_1"

        // flutter_local_notifications 21.0.0 requires Android API 24 or higher.
        minSdk = 24

        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        multiDexEnabled = true
    }

    buildTypes {
        release {
            // Replace with a production signing configuration before publishing.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Required by flutter_local_notifications.
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}