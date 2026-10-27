import java.io.FileInputStream
import java.util.Properties

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties().apply {
    if (keystorePropertiesFile.exists()) {
        load(FileInputStream(keystorePropertiesFile))
    }
}

// versionCode: CI sets VERSION_CODE from its run number (android-release.yml), so
// every upload gets a new code, even a second run on the same commit. Without it
// (local builds) it falls back to the git commit count plus 100. Play refuses any
// versionCode it has already seen; don't upload local builds, they would take
// codes CI hasn't reached yet. Falls back to 1 if git isn't available.
val versionCodeOffset = 100
val gitVersionCode: Int = providers.environmentVariable("VERSION_CODE").orNull?.toIntOrNull()
    ?: try {
        versionCodeOffset + providers.exec {
            commandLine("git", "rev-list", "--count", "HEAD")
        }.standardOutput.asText.get().trim().toInt()
    } catch (e: Exception) {
        1
    }

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.mouadfhm.fitness_tracker_front"

    // Compile/target SDK set to 36 (Android 16) per Play requirements
    compileSdk = 36
    ndkVersion = "28.2.13676358"

    compileOptions {
        // Required by flutter_local_notifications.
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    defaultConfig {
        applicationId = "com.mouadfhm.fitness_tracker_front"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = gitVersionCode
        versionName = "2.1"
    }

    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            // Ship native debug symbols in the bundle so Play can symbolicate
            // native crashes and ANRs (Play warns when they're missing).
            ndk {
                debugSymbolLevel = "SYMBOL_TABLE"
            }
            // Enable minify/R8 if you want smaller/obfuscated builds. Keep rules must be present.
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
        // You can keep debug as default; Flutter will use debug signing for debug runs.
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")

    // Only include the specific Play libraries you actually need (do NOT include com.google.android.play:core)
    implementation("com.google.android.play:feature-delivery:2.1.0")
    implementation("com.google.android.play:asset-delivery:2.2.2")
    implementation("com.google.android.play:app-update:2.1.0")
    implementation("com.google.android.play:review:2.0.1")

    // Keep other app dependencies (if you have any module-specific ones)
    // For example, if your project requires androidx libraries, they belong here too.
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_11
    }
}

flutter {
    source = "../.."
}
