allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

subprojects {
    val bumpCompileSdk: () -> Unit = {
        extensions.findByType(com.android.build.gradle.LibraryExtension::class.java)?.let {
            it.compileSdk = 36
        }
    }
    if (state.executed) bumpCompileSdk() else afterEvaluate { bumpCompileSdk() }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
