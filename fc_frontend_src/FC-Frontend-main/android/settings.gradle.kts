pluginManagement {
    val flutterSdkPath =
        run {
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
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    // AGP 9.0.1 broke debug resource linking (missing appcompat abc_* layouts).
    // Release could build; debug could not. 8.9.x is stable for flutter run.
    id("com.android.application") version "8.9.1" apply false
    id("com.android.library") version "8.9.1" apply false
    id("org.jetbrains.kotlin.android") version "2.1.20" apply false
}

include(":app")

// flutter_libserialport 0.6.0's Android script calls jcenter(), which Gradle 9
// removed, and then builds a USB library this phone build does not use.
val serialPortPlugin = settings.findProject(":flutter_libserialport")
if (serialPortPlugin != null) {
    serialPortPlugin.projectDir = file("stubs/flutter_libserialport/android")
}
