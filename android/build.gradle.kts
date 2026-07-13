plugins {
    id("com.android.library")
    id("org.jetbrains.kotlin.android")
}

group = "com.trueid.sdk.documentflutter"
version = "1.0.1"

android {
    namespace = "com.trueid.sdk.documentflutter"
    compileSdk = 35

    defaultConfig {
        minSdk = 24
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }
}

repositories {
    google()
    mavenCentral()
    maven { url = uri("https://app.trueid.info/sdk/android") }
    maven { url = uri("https://jitpack.io") }
}

dependencies {
    val localDocumentSdk = findProject(":trueid-document-sdk")
    if (localDocumentSdk != null) {
        add("implementation", localDocumentSdk)
    } else {
        add("implementation", "com.trueid.sdk:trueid-document-sdk:1.1.1")
    }
}
