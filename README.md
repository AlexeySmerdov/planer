# Flutter Task Planner 📋

A modern, feature-rich task planning application built with Flutter, featuring smart text editing, tag management, and cross-platform support.

## 🌟 Features

### 📝 Smart Text Editor
- **Enhanced Text Editing**: Advanced text editor with smart formatting capabilities
- **Auto Lists**: Type `-` for bullet points, `1` for numbered lists
- **Smart Continuation**: Press Enter to automatically continue lists
- **Strikethrough Support**: Select text and press `Ctrl+Shift+X` to strikethrough
- **Tab Indentation**: Use Tab/Shift+Tab for nested lists
- **Visual Markdown**: Real-time rendering of `~~strikethrough~~` text

### 🏷️ Advanced Tag System
- **Unified Tag Management**: Single database for tags across all screens
- **Color-Coded Tags**: Automatic color assignment and synchronization
- **Quick Tag Selection**: Touch-friendly tag pills interface
- **Tag Statistics**: Usage tracking and management
- **Auto-Save**: Automatic saving of new tags to Firestore

### 📅 Task Management
- **Daily Planning**: Separate screens for today's and tomorrow's tasks
- **Rich Text Support**: Full formatting capabilities in task descriptions
- **Auto-Save**: Automatic saving when focus is lost
- **Task Creation**: Streamlined task creation with tag support

### 🔐 Authentication & Sync
- **Firebase Authentication**: Secure Google Sign-In
- **Cloud Sync**: Real-time synchronization with Firestore
- **Offline Support**: Local SQLite database for offline functionality
- **Cross-Platform**: Works on Web, Android, iOS, Windows, macOS, and Linux

## 🚀 Live Demo

**Web App**: [https://alexeysmerdov.github.io/planer/](https://alexeysmerdov.github.io/planer/)

## 🛠️ Tech Stack

- **Framework**: Flutter 3.24.0
- **Language**: Dart
- **Backend**: Firebase (Firestore, Authentication)
- **Local Storage**: SQLite
- **State Management**: Provider
- **UI**: Material Design 3
- **Deployment**: GitHub Pages, Firebase Hosting

## 📱 Platform Support

- ✅ **Web** (Chrome, Firefox, Safari, Edge)
- ✅ **Android** (API 21+)
- ✅ **iOS** (iOS 12+)
- ✅ **Windows** (Windows 10+)
- ✅ **macOS** (macOS 10.14+)
- ✅ **Linux** (Ubuntu 18.04+)

## 🎯 Smart Editor Features

### Keyboard Shortcuts
- `Ctrl+Shift+X` - Toggle strikethrough on selected text
- `Tab` - Increase indentation
- `Shift+Tab` - Decrease indentation
- `Enter` - Continue list automatically

### Auto-Formatting
- Type `-` → Converts to `•` (bullet point)
- Type `1` → Converts to `1.` (numbered list)
- `~~text~~` → Displays as ~~strikethrough~~

### Toolbar Actions
- 🔘 Insert bullet point
- 🔢 Insert numbered list  
- ~~S~~ Toggle strikethrough

## 🏗️ Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   └── task.dart
├── providers/                # State management
│   ├── auth_provider.dart
│   ├── task_provider.dart
│   └── theme_provider.dart
├── screens/                  # UI screens
│   ├── auth_screen.dart
│   ├── daily_tasks_screen.dart
│   ├── home_screen.dart
│   ├── tags_management_screen.dart
│   └── task_detail_screen.dart
├── services/                 # Business logic
│   ├── auth_service.dart
│   ├── database_helper.dart
│   ├── firestore_service.dart
│   ├── tag_service.dart
│   └── user_service.dart
├── widgets/                  # Reusable components
│   ├── enhanced_tag_input.dart
│   ├── enhanced_text_editor.dart
│   ├── index_status_widget.dart
│   └── tag_chip.dart
└── utils/                    # Utilities
    ├── index_monitor.dart
    ├── responsive.dart
    └── time_formatter.dart
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.24.0 or higher
- Dart SDK 3.5.0 or higher
- Firebase project (for cloud features)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/AlexeySmerdov/planer.git
   cd planer
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase** (Optional - for cloud sync)
   - Create a Firebase project
   - Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Update `lib/firebase_options.dart` with your config

4. **Run the app**
   ```bash
   # Web
   flutter run -d chrome
   
   # Android
   flutter run -d android
   
   # iOS
   flutter run -d ios
   
   # Desktop
   flutter run -d windows
   flutter run -d macos
   flutter run -d linux
   ```

## 🔧 Build for Production

### Web
```bash
flutter build web --release
```

### Mobile
```bash
# Android
flutter build apk --release
flutter build appbundle --release

# iOS
flutter build ios --release
```

### Desktop
```bash
# Windows
flutter build windows --release

# macOS
flutter build macos --release

# Linux
flutter build linux --release
```

## 🌐 Deployment

### GitHub Pages (Automatic)
The app automatically deploys to GitHub Pages on every push to the master branch via GitHub Actions.

### Firebase Hosting
```bash
firebase deploy --only hosting
```

## 🎨 Features in Detail

### Enhanced Text Editor
The smart text editor provides a rich editing experience with:
- **Adaptive Interface**: Different modes for mobile and desktop
- **Smart Lists**: Automatic bullet points and numbering
- **Visual Feedback**: Real-time strikethrough rendering
- **Keyboard Shortcuts**: Desktop-optimized shortcuts
- **Touch-Friendly**: Mobile-optimized interface

### Tag Management System
- **Centralized Management**: Single source of truth for all tags
- **Color Coordination**: Automatic color assignment and sync
- **Usage Analytics**: Track tag usage across tasks
- **Quick Access**: One-tap tag selection during task creation

### Cross-Platform Compatibility
- **Responsive Design**: Adapts to different screen sizes
- **Platform-Specific Features**: Optimized for each platform
- **Offline-First**: Works without internet connection
- **Cloud Sync**: Seamless synchronization when online

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- Material Design for UI guidelines
- Community contributors and testers

## 📞 Support

If you have any questions or need help, please:
- Open an issue on GitHub
- Check the documentation
- Contact the maintainer

---

**Made with ❤️ using Flutter**
