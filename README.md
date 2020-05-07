# ClinTwin360_iOS
Repo for the ClinTwin360 participant app.

Requires Xcode 11.3.1 or later.

There are a few steps that need to be followed in order to run the app using Xcode:

1. First, you will need to ensure you have Cocoapods installed on your computer. If you do not, it can be installed with the command 'sudo gem install cocoapods'. Further details on Cocoapods installation can be found here: https://guides.cocoapods.org/using/getting-started.html.
2. After cloning the repository, using Terminal, cd into the repo directory, then use the 'pod install' command. You should not have Xcode running while doing this.
3. Once the pods have completed installing, you may open the ClinTwin360.xcworkspace file. Note: you will not be able to
  run the project if you open the ClinTwin360.xcodeproj file instead.
4. Press the build (play) button in the upper left corner of the Xcode console to build and run the project.

Here are links to information about the included frameworks:
Alamofire (a networking framework) - https://github.com/Alamofire/Alamofire
ResearchKit (for creating medical surveys) - https://github.com/researchkit/researchkit

It should be of note that the ResearchKit framework was initially included as a Cocoapod, but has since had the framework's files manually included in the project due to deprecation of UIWebView, which was still utilized in the latest stable version of ResearchKit (v2.0). Thus, any portions of the framework which had used UIWebView have been manually removed. This manually imported version of ResearchKit also does not support localization.
As soon as a new, stable version of ResearchKit is released, it can be added back as a pod by removing the ResearchKit folders from the project, uncommenting the 'pod 'ResearchKit'' line in the Podfile, and using the 'pod install' command again.

This project can be extended by changing the bundle identifier in the project's general settings. The display name can also be
changed. Before the app can be built on a physical device or uploaded to TestFlight or the App Store, users who extend the
project will need to create and use their own development and distribution certificates, and potentially their own provisioning profile if not managing code signing automatically.
