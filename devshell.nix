{ pkgs, defaultBuildToolsVersion }:
with pkgs; let
  # android-studio is not available in aarch64-darwin
  conditionalPackages =
    if pkgs.system != "aarch64-darwin"
    then [android-studio]
    else [];

  avdRoot = "$PWD/.android/avd";
in
  with pkgs;
  # Configure your development environment.
  #
  # Documentation: https://github.com/numtide/devshell
    devshell.mkShell {
      name = "android-project";
      motd = ''
        Entered the Android app development environment.
      '';

      env = [
        {
          name = "ANDROID_HOME";
          value = "${android-sdk}/share/android-sdk";
        }
        {
          name = "ANDROID_SDK_ROOT";
          value = "${android-sdk}/share/android-sdk";
        }
        {
          name = "JAVA_HOME";
          value = openjdk17.home;
        }
        {
          name = "GRADLE_HOME";
          value = "${gradle}/bin";
        }
        {
          name = "GRADLE_OPTS";
          value = "-Dorg.gradle.java.home=${openjdk17.home} -Dorg.gradle.project.android.aapt2FromMavenOverride=${android-sdk}/share/android-sdk/build-tools/${defaultBuildToolsVersion}/aapt2";
        }
      ];
      packages =
        [
          android-sdk
          gradle
          openjdk17
          cmake
          # expo
          watchman
          nodejs_22
          ninja
        ]
        ++ conditionalPackages;

      devshell.startup.avdroot.text = ''
        echo "Creating android avd root as ${avdRoot}"
        mkdir -p "${avdRoot}"

        echo "Exporting ANDROID_AVD_HOME"
        export ANDROID_AVD_HOME="${avdRoot}"

      '';
    }
