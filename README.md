# 🗑️ Trash2Cash Mobile App

**Trash2Cash** is a Flutter-based mobile application that transforms recycling into a rewarding and user-friendly experience. Users can track recyclable items, earn points, view rewards, and interact with an eco-friendly backend system that motivates sustainability and responsible waste management.

This app is part of the broader **Trash2Cash** ecosystem which connects individuals, recycling centers, and reward incentives to transform trash into value.

---

## 🔎 Features

- 📍 User Authentication (Login / Register)
- 🧑‍💼 User Profile with points and eco-level
- 📊 Point History & Recent Activity
- 📸 Profile Image Handling (Cached, optimized)
- 🔐 Secure API integration with backend
- 📡 QR Code Scan / Display (one-time use workflows)
- 🚀 Responsive UI across mobile platforms
- 🪄 Extensible codebase with best practices

This project uses a **Django backend** to manage users, awards points, and power transactional features. A companion backend repository should exist to support endpoints such as `/api/auth/`, `/api/points/`, and `/api/points/qr-scan/`.

---

## 📦 Tech Stack

| Layer | Technology |
|-------|------------|
| Frontend | Flutter (Dart) |
| State Management | Provider / Flutter State |
| Networking | Dio / CachedNetworkImage |
| QR | qr_flutter (or equivalent QR display/scanner) |
| Backend | Django REST API (separate repository) |
| Storage | Shared Preferences / Secure Storage |

---

## 📁 Repository Structure

```
trash2cash/
├── .vscode/
├── .gitignore
├── .metadata
├── analysis_options.yaml
├── pubspec.lock
├── pubspec.yaml
├── README.md
├── .dart_tool/
├── .idea/
├── android/
│   ├── .gitignore
│   ├── build.gradle.kts
│   ├── gradle.properties
│   ├── settings.gradle.kts
│   ├── .gradle/
│   ├── .kotlin/
│   ├── app/
│   │   ├── build.gradle.kts
│   │   ├── src/
│   │   │   ├── debug/
│   │   │   │   └── AndroidManifest.xml
│   │   │   ├── main/
│   │   │   │   ├── AndroidManifest.xml
│   │   │   │   ├── java/
│   │   │   │   │   └── io/
│   │   │   │   │       └── flutter/
│   │   │   │   │           └── plugins/
│   │   │   │   ├── kotlin/
│   │   │   │   │   └── com/
│   │   │   │   │       └── example/
│   │   │   │   │           └── trash2cash/
│   │   │   │   │               └── MainActivity.kt
│   │   │   │   └── res/
│   │   │   │       ├── drawable/
│   │   │   │       │   └── launch_background.xml
│   │   │   │       ├── drawable-v21/
│   │   │   │       │   └── launch_background.xml
│   │   │   │       ├── mipmap-hdpi/
│   │   │   │       │   └── ic_launcher.png
│   │   │   │       ├── mipmap-mdpi/
│   │   │   │       │   └── ic_launcher.png
│   │   │   │       ├── mipmap-xhdpi/
│   │   │   │       │   └── ic_launcher.png
│   │   │   │       ├── mipmap-xxhdpi/
│   │   │   │       │   └── ic_launcher.png
│   │   │   │       ├── mipmap-xxxhdpi/
│   │   │   │       │   └── ic_launcher.png
│   │   │   │       ├── values/
│   │   │   │       │   └── styles.xml
│   │   │   │       └── values-night/
│   │   │   │           └── styles.xml
│   │   │   └── profile/
│   │   │       └── AndroidManifest.xml
│   ├── build/
│   │   └── reports/
│   │       └── problems/
│   │           └── problems-report.html
│   └── gradle/
│       └── wrapper/
│           └── gradle-wrapper.properties
├── assets/
│   └── images/
│       ├── image.png
│       ├── image1.png
│       └── logo.png
├── ios/
│   ├── .gitignore
│   ├── Flutter/
│   │   ├── AppFrameworkInfo.plist
│   │   ├── Debug.xcconfig
│   │   ├── Release.xcconfig
│   │   └── ephemeral/
│   ├── Runner/
│   │   ├── AppDelegate.swift
│   │   ├── Info.plist
│   │   ├── Runner-Bridging-Header.h
│   │   ├── Assets.xcassets/
│   │   │   ├── AppIcon.appiconset/
│   │   │   │   ├── Contents.json
│   │   │   │   ├── Icon-App-20x20@1x.png
│   │   │   │   ├── Icon-App-20x20@2x.png
│   │   │   │   ├── Icon-App-20x20@3x.png
│   │   │   │   ├── Icon-App-29x29@1x.png
│   │   │   │   ├── Icon-App-29x29@2x.png
│   │   │   │   ├── Icon-App-29x29@3x.png
│   │   │   │   ├── Icon-App-40x40@1x.png
│   │   │   │   ├── Icon-App-40x40@2x.png
│   │   │   │   ├── Icon-App-40x40@3x.png
│   │   │   │   ├── Icon-App-60x60@2x.png
│   │   │   │   ├── Icon-App-60x60@3x.png
│   │   │   │   ├── Icon-App-76x76@1x.png
│   │   │   │   ├── Icon-App-76x76@2x.png
│   │   │   │   ├── Icon-App-83.5x83.5@2x.png
│   │   │   │   └── Icon-App-1024x1024@1x.png
│   │   │   └── LaunchImage.imageset/
│   │   │       ├── Contents.json
│   │   │       ├── LaunchImage.png
│   │   │       ├── LaunchImage@2x.png
│   │   │       ├── LaunchImage@3x.png
│   │   │       └── README.md
│   │   ├── Base.lproj/
│   │   │   ├── LaunchScreen.storyboard
│   │   │   └── Main.storyboard
│   │   └── Runner.xcodeproj/
│   │       ├── project.pbxproj
│   │       ├── project.xcworkspace/
│   │       │   ├── contents.xcworkspacedata
│   │       │   └── xcshareddata/
│   │       │       ├── IDEWorkspaceChecks.plist
│   │       │       └── WorkspaceSettings.xcsettings
│   │       └── xcshareddata/
│   │           └── xcschemes/
│   │               └── Runner.xcscheme
│   ├── Runner.xcworkspace/
│   │   ├── contents.xcworkspacedata
│   │   └── xcshareddata/
│   │       ├── IDEWorkspaceChecks.plist
│   │       └── WorkspaceSettings.xcsettings
│   └── RunnerTests/
│       └── RunnerTests.swift
├── lib/
│   ├── main.dart
│   ├── core/
│   │   ├── constants/
│   │   │   ├── api_constants.dart
│   │   │   ├── api_exceptions.dart
│   │   │   ├── auth_interceptor.dart
│   │   │   └── dio_client.dart
│   │   ├── helper/
│   │   │   ├── image_helper.dart
│   │   │   └── qr_scanner_service.dart
│   │   ├── network/
│   │   │   └── network_info.dart
│   │   └── storage/
│   │       ├── shared_prefs.dart
│   │       └── token_refresh_service.dart
│   └── features/
│       ├── auth/
│       │   ├── data/
│       │   │   ├── model/
│       │   │   │   └── user_model.dart
│       │   │   └── services/
│       │   │       ├── auth_service.dart
│       │   │       └── profile_service.dart
│       │   └── presentation/
│       │       ├── provider/
│       │       │   ├── auth_provider.dart
│       │       │   └── profile_provider.dart
│       │       ├── screen/
│       │       │   ├── login_screen.dart
│       │       │   ├── sign_up.dart
│       │       │   └── splash_screen.dart
│       │       └── widgets/
│       │           ├── Input_format.dart
│       │           └── transfer_screen_wrapper.dart
│       ├── home/
│       │   ├── data/
│       │   │   ├── model/
│       │   │   │   └── recycling_data.dart
│       │   │   └── services/
│       │   │       └── scan_service.dart
│       │   └── presentation/
│       │       ├── provider/
│       │       │   └── scan_provider.dart
│       │       ├── screen/
│       │       │   ├── about_page.dart
│       │       │   ├── edit_profile_screen.dart
│       │       │   └── home_screen.dart
│       │       └── widget/
│       │           ├── qr_sacnner_page.dart
│       │           └── side_bar.dart
│       ├── onboarding/
│       │   ├── presentation/
│       │   │   └── Screen/
│       │   │       └── onboarding_page.dart
│       │   └── widget/
│       │       └── app_button.dart
│       └── transactions/
│           ├── data/
│           │   ├── model/
│           │   │   └── history_model.dart
│           │   └── services/
│           │       ├── history_response.dart
│           │       ├── history_service.dart
│           │       └── transfer_service.dart
│           └── presentation/
│               ├── provider/
│               │   ├── histrory_provider.dart
│               │   └── transfer_provider.dart
│               ├── screen/
│               │   ├── history_screen.dart
│               │   └── transfer_screen.dart
│               └── widgets/
└── linux/
    ├── .gitignore
    ├── CMakeLists.txt
    ├── flutter/
    │   ├── CMakeLists.txt
    │   ├── generated_plugin_registrant.cc
    │   ├── generated_plugin_registrant.h
    │   ├── generated_plugins.cmake
    │   └── ephemeral/
```

---

## 🚀 Getting Started

### 🛠 Requirements

Make sure you have the following installed:

- Flutter SDK (>= 3.0)
- Dart SDK (comes with Flutter)
- Android Studio or VS Code
- Android / iOS simulators or physical devices

### 📌 Installation Steps

1. **Clone the repo**
git clone https://github.com/RewardingTrashcanSystem/Trash2Cash_Mobile.git
2. flutter pub get 
