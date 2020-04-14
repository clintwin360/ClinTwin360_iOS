# ClinTwin360_iOS
Repo for the ClinTwin360 participant app.

Requires Xcode 11.3.1 or later.

There are a few steps that need to be followed in order to run the app using Xcode:

1. After cloning the repository, using Terminal, cd into the repo directory, then use the 'pod install' command.
2. Once the pods have completed installing, you may open the ClinTwin360.xcworkspace file. Note: you will not be able to
  run the project if you open the ClinTwin360.xcodeproj file instead.
3. Press the build (play) button in the upper left corner of the Xcode console to build and run the project.

This project can be extended by changing the bundle identifier in the project's general settings. The display name can also be
changed. Before the app can be built on a physical device or uploaded to TestFlight or the App Store, users who extend the
project will need to create and use their own development and distribution certificates, and potentially their own provisioning
profile if not managing code signing automatically.
