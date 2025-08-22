allprojects {
    repositories {
        google()
        mavenCentral()
        
        // Repository tambahan untuk menangani error checkReleaseAarMetadata
        maven {
            url = uri("https://repo1.maven.org/maven2")
        }
        
        // Repository untuk plugin file_picker (menggunakan mavenCentral sebagai alternatif jcenter)
        maven {
            url = uri("https://maven.google.com")
        }
    }
}

// Memperbaiki penggunaan buildDir yang deprecated
rootProject.layout.buildDirectory.set(file("../build"))
subprojects {
    project.layout.buildDirectory.set(file("${rootProject.layout.buildDirectory.get()}/${project.name}"))
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory.get())
}

subprojects {
    afterEvaluate { 
        if (project.plugins.hasPlugin("com.android.application") ||
            project.plugins.hasPlugin("com.android.library")) {
            project.extensions.configure<com.android.build.gradle.BaseExtension> {
                compileSdkVersion(34)
                
                // Konfigurasi tambahan untuk menangani error checkReleaseAarMetadata
                aaptOptions {
                    noCompress += listOf("tflite", "lite", "model", "dat")
                }
                
                // Konfigurasi untuk menangani error checkReleaseAarMetadata dengan file_picker
                packagingOptions {
                    resources {
                        excludes += listOf(
                            "META-INF/DEPENDENCIES",
                            "META-INF/LICENSE",
                            "META-INF/LICENSE.txt",
                            "META-INF/license.txt",
                            "META-INF/NOTICE",
                            "META-INF/NOTICE.txt",
                            "META-INF/notice.txt",
                            "META-INF/ASL2.0",
                            "META-INF/*.kotlin_module",
                            "META-INF/AL2.0",
                            "META-INF/LGPL2.1"
                        )
                    }
                }
            }
        }
    }
}

// Konfigurasi tambahan untuk menangani masalah kompatibilitas
subprojects {
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
}
