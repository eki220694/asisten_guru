pluginManagement {
    val flutterSdkPath = run {
        val properties = java.util.Properties()
        file("local.properties").inputStream().use { properties.load(it) }
        val flutterSdkPath = properties.getProperty("flutter.sdk")
        require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
        flutterSdkPath
    }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
    
    // Konfigurasi untuk menangani error checkReleaseAarMetadata
    resolutionStrategy {
        eachPlugin {
            if (requested.id.id == "com.android.application") {
                useModule("com.android.tools.build:gradle:8.12.0")
            }
        }
    }
}

// Konfigurasi untuk menangani error checkReleaseAarMetadata
gradle.projectsLoaded {
    gradle.rootProject.allprojects.forEach { project ->
        project.configurations.all {
            resolutionStrategy {
                force("com.android.tools.build:gradle:8.12.0")
            }
        }
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.12.0" apply false
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
}

include(":app")

// Menangani konflik dependency untuk file_picker
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.PREFER_SETTINGS)
    repositories {
        google()
        mavenCentral()
        
        // Repository tambahan untuk menangani error checkReleaseAarMetadata
        maven {
            url = uri("https://repo1.maven.org/maven2")
        }
        
        // Repository untuk plugin file_picker
        maven {
            url = uri("https://jcenter.bintray.com")
        }
    }
}
