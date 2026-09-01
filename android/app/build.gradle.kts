plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.questlog.questlog"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    // Removed the deprecated kotlinOptions block from here

    defaultConfig {
        applicationId = "com.questlog.questlog"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
    
    // Updated renaming block for ABI splits
    applicationVariants.configureEach {
        val variant = this
        outputs.configureEach {
            val outputImpl = this as com.android.build.gradle.internal.api.BaseVariantOutputImpl
            
            // Get the architecture name (e.g., arm64-v8a), or default to "universal"
            val abi = outputImpl.getFilter(com.android.build.OutputFile.ABI) ?: "universal"
            
            // Add the ABI to the file name to prevent collisions!
            outputImpl.outputFileName = "questlog-v${variant.versionName}+${variant.versionCode}-${abi}-${variant.name}.apk"
        }
    }
}

// Added the new compilerOptions block here (outside of the android block)
kotlin {
    compilerOptions {
        jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}
