# app-flutter

Lectary 4 - A sign language learning application.

This time, it is Flutter.

In this project, the existing Lectary-app is reimplemented and extended using the flutter framework.

## Getting Started
First install the Flutter framework and setup your environment based on your OS:

You can setup Flutter manually or use the version management tool FVM (see next point).

[Install Flutter](https://flutter.dev/docs/get-started/install)

Have a look on [online documentation](https://flutter.dev/docs) for further information.

## FVM - flutter version management 
For using [FVM](https://pub.dev/packages/fvm), follow the installation instructions on the package site.

Then, for installing flutter based on the specified version in the fvm config file `.fvm/fvm_config.json`, just run the command `fvm install`.

All further dart or flutter commands can be executed by means of fvm command proxy, e.g. `fvm flutter run`. 

### Building and running on Android.
For running the app on android, just connect your device or start an android-emulator and run the following command from your console window
```flutter run```

### Building and running on iOS.
For running the app on iOS a Mac with Xcode is needed. 
Then connect your device or start the simulator and run the following command from your console window
```flutter run``` 

## Tests
For running all tests in the test-directory run the following command from your console window
```flutter test test```

For running a single test, use the following command
```flutter test test/<file-path>```

## Re-Generating auto-generated code from plugins
Some plugins are using code generation.
For doing so, run the following command from your console window
```flutter pub run build_runner build --delete-conflicting-outputs```

