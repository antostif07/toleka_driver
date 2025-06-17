    allprojects {
    repositories {
        google()
        mavenCentral()

//        maven {
//            url 'https://api.mapbox.com/downloads/v2/releases/maven'
//            authentication {
//                basic(BasicAuthentication)
//            }
//            credentials {
//                username = "mapbox" // Ceci est littéralement "mapbox"
//                password = "sk.eyJ1IjoiYW50b3N0aXVzaGluZGkiLCJhIjoiY21icW5wM3cyMDFicjJsc2E0amYyZGQ0cyJ9.QozhRkmM-n4W_I45cSUQqg"
//            }
//        }
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
