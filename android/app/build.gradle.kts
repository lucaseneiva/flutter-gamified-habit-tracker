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

android {
    namespace = "com.example.firy_streak"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

	signingConfigs {
		create("release") {
			val keyProperties = Properties()
			val keyPropertiesFile = rootProject.file("key.properties")
			if (keyPropertiesFile.exists()) {
				keyProperties.load(FileInputStream(keyPropertiesFile))
			}
			println("key.properties file path: ${keyPropertiesFile.absolutePath}")
			println("Exists? = ${keyPropertiesFile.exists()}")

			keyAlias = keyProperties["keyAlias"] as String
			keyPassword = keyProperties["keyPassword"] as String
			storeFile = file(keyProperties["storeFile"] as String)
			storePassword = keyProperties["storePassword"] as String
		}
	}

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.firy_streak"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}
