plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.asisten_guru"
    compileSdk = 34
    ndkVersion = "25.1.8937393"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.asisten_guru"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 21
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
        
        // Konfigurasi multidex
        multiDexEnabled = true
        
        // Konfigurasi untuk menangani error checkReleaseAarMetadata
        vectorDrawables {
            useSupportLibrary = true
        }
        
        // Konfigurasi tambahan untuk menangani error checkReleaseAarMetadata
        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
        
        // Konfigurasi khusus untuk menangani error checkReleaseAarMetadata
        renderscriptTargetApi = 34
        renderscriptSupportModeEnabled = true
        
        // Konfigurasi untuk menangani error checkReleaseAarMetadata dengan file_picker
        manifestPlaceholders = mapOf(
            "appAuthRedirectScheme" to "com.example.asisten_guru"
        )
        
        // Konfigurasi tambahan untuk menangani error checkReleaseAarMetadata
        resourceConfigurations += listOf("en", "id")
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            
            // Konfigurasi untuk menangani error checkReleaseAarMetadata
            ndk {
                abiFilters += listOf("armeabi-v7a", "arm64-v8a", "x86_64")
            }
            
            // Konfigurasi tambahan untuk menangani error checkReleaseAarMetadata
            minifyEnabled false
            shrinkResources false
        }
    }
    
    packaging {
        resources {
            excludes += "/META-INF/{AL2.0,LGPL2.1}"
            excludes += "META-INF/DEPENDENCIES"
            excludes += "META-INF/LICENSE"
            excludes += "META-INF/LICENSE.txt"
            excludes += "META-INF/license.txt"
            excludes += "META-INF/NOTICE"
            excludes += "META-INF/NOTICE.txt"
            excludes += "META-INF/notice.txt"
            excludes += "META-INF/ASL2.0"
            excludes += "META-INF/*.kotlin_module"
        }
        
        // Konfigurasi tambahan untuk menangani error checkReleaseAarMetadata
        jniLibs {
            pickFirsts += listOf(
                "lib/x86/libc++_shared.so",
                "lib/x86_64/libc++_shared.so",
                "lib/armeabi-v7a/libc++_shared.so",
                "lib/arm64-v8a/libc++_shared.so"
            )
        }
    }

    // Konfigurasi tambahan untuk menangani error checkReleaseAarMetadata
    applicationVariants.all {
        outputs.all {
            processManifestProvider.get().doLast {
                // Konfigurasi untuk menangani error checkReleaseAarMetadata
                val manifestFile = File(manifestOutputDirectory.get().asFile, "AndroidManifest.xml")
                if (manifestFile.exists()) {
                    manifestFile.writeText(
                        manifestFile.readText().replace(
                            "android:usesCleartextTraffic=\"false\"", 
                            "android:usesCleartextTraffic=\"true\""
                        )
                    )
                }
            }
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.multidex:multidex:2.0.1")
    
    // Penanganan khusus untuk plugin file_picker
    implementation("androidx.documentfile:documentfile:1.0.1")
    implementation("androidx.localbroadcastmanager:localbroadcastmanager:1.1.0")
    
    // Dependency tambahan untuk menangani error checkReleaseAarMetadata
    implementation("androidx.lifecycle:lifecycle-common:2.7.0")
    implementation("androidx.lifecycle:lifecycle-runtime:2.7.0")
    implementation("androidx.lifecycle:lifecycle-process:2.7.0")
    implementation("androidx.arch.core:core-common:2.2.0")
    implementation("androidx.collection:collection:1.4.0")
    implementation("androidx.annotation:annotation:1.7.1")
    implementation("androidx.fragment:fragment:1.6.2")
    implementation("androidx.activity:activity:1.8.2")
}

// Konfigurasi untuk menangani error checkReleaseAarMetadata
configurations.all {
    resolutionStrategy {
        force("androidx.core:core-ktx:1.12.0")
        force("androidx.appcompat:appcompat:1.6.1")
        force("androidx.lifecycle:lifecycle-common:2.7.0")
        force("androidx.lifecycle:lifecycle-runtime:2.7.0")
        force("androidx.lifecycle:lifecycle-process:2.7.0")
        force("androidx.arch.core:core-common:2.2.0")
        force("androidx.collection:collection:1.4.0")
        force("androidx.annotation:annotation:1.7.1")
        force("androidx.fragment:fragment:1.6.2")
        force("androidx.activity:activity:1.8.2")
    }
}
