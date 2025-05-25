import com.android.build.gradle.AppExtension
import com.android.build.gradle.LibraryExtension

allprojects {
    repositories {
        google()
        mavenCentral()
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

subprojects {
  // Für Library-Module (com.android.library)
  plugins.withId("com.android.library") {
    extensions.configure(LibraryExtension::class.java) {
      if (namespace.isNullOrBlank()) {
        namespace = project.group?.toString() ?: "com.example.${project.name}"
      }
    }
  }
  // Für App-Module (com.android.application)
  plugins.withId("com.android.application") {
    extensions.configure(AppExtension::class.java) {
      if (namespace.isNullOrBlank()) {
        namespace = project.group?.toString() ?: "com.example.${project.name}"
      }
    }
  }
}
