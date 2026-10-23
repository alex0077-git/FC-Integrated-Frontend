// Stand-in for flutter_libserialport's Android build.
// The published plugin calls jcenter() and compiles a USB native library.
// This phone app talks to the transmitter over Bluetooth SPP and WiFi.
group = "org.sigrok.flutter_libserialport"
version = "0.6.0"

plugins {
    id("com.android.library")
}

android {
    namespace = "org.sigrok.flutter_libserialport"
    compileSdk = 36

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        minSdk = 24
    }
}
