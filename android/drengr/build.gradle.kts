import com.vanniktech.maven.publish.SonatypeHost

plugins {
    id("com.android.library")
    id("org.jetbrains.kotlin.android")
    id("maven-publish")
    id("com.vanniktech.maven.publish")
}

android {
    namespace = "dev.drengr.sdk"
    compileSdk = 34

    defaultConfig {
        minSdk = 21
        consumerProguardFiles("consumer-rules.pro")
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions { jvmTarget = "17" }
    testOptions { unitTests.isReturnDefaultValues = true }

    // NOTE: no `publishing { singleVariant("release") }` here — the vanniktech
    // plugin below configures the "release" variant publication itself; declaring
    // it in both places throws "Using singleVariant publishing DSL multiple times".
}

dependencies {
    implementation("com.squareup.okhttp3:okhttp:4.12.0")
    testImplementation("junit:junit:4.13.2")
    testImplementation("org.json:json:20240303")
    testImplementation("com.squareup.okhttp3:mockwebserver:4.12.0")
}

// JitPack calls `./gradlew :drengr:publishToMavenLocal` (see jitpack.yml at repo root).
// JitPack repackages the produced artifact under its own group/artifact/tag scheme
// regardless of what's declared here, so these values only matter for local testing.
afterEvaluate {
    publishing {
        publications {
            create<MavenPublication>("jitpack") {
                from(components["release"])
                groupId = "com.github.SharminSirajudeen"
                artifactId = "drengr"
                version = "0.11.0"
            }
        }
    }
}

// Maven Central (Central Portal) via the vanniktech plugin. Coordinates below.
// Signing + upload credentials come from env vars / gradle.properties at publish
// time ONLY (see gradle.properties for the exact names) — never hardcoded here.
mavenPublishing {
    publishToMavenCentral(SonatypeHost.CENTRAL_PORTAL)
    signAllPublications()

    coordinates("dev.drengr", "analytics-android", "0.11.0")

    pom {
        name.set("Drengr Analytics (Android)")
        description.set(
            "0-code mobile analytics SDK for Android — captures network + behavior, " +
                "redacts PII on-device."
        )
        url.set("https://drengr.dev")
        licenses {
            license {
                name.set("Apache-2.0")
                url.set("https://www.apache.org/licenses/LICENSE-2.0.txt")
                distribution.set("repo")
            }
        }
        developers {
            developer {
                id.set("SharminSirajudeen")
                name.set("Sharmin Sirajudeen")
                email.set("sharminsirajudeen11@gmail.com")
            }
        }
        scm {
            url.set("https://github.com/SharminSirajudeen/drengr-community")
            connection.set("scm:git:git://github.com/SharminSirajudeen/drengr-community.git")
            developerConnection.set(
                "scm:git:ssh://git@github.com/SharminSirajudeen/drengr-community.git"
            )
        }
    }
}
