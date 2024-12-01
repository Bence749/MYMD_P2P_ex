# P2P Exam Flutter Application

This document provides a comprehensive overview of the P2P Exam Flutter application, which is designed for peer-to-peer file sharing with features such as user authentication, torrent management, and secure data handling.

## Project Overview

The application allows users to register, login, view available torrents, purchase them, and upload new ones. It features a credit system and uses secure storage for sensitive information.

## Project Structure

```
lib/
├── main.dart
├── screens/
│   ├── auth_screen.dart
│   ├── home_screen.dart
│   ├── file_list_screen.dart
│   └── settings_screen.dart
├── models/
│   └── file_model.dart
├── services/
│   ├── auth_service.dart
│   └── torrent_management.dart
└── widgets/
    └── file_item.dart
```

## Screens

### AuthScreen

- **Purpose**: Handles user authentication.
- **Features**:
    - Login and registration forms.
    - Input validation for username, email (for registration), and password.
    - Utilizes `FileService` for authentication operations.

### HomeScreen

- **Purpose**: Main navigation hub.
- **Features**:
    - Uses a `BottomNavigationBar` for switching between sections.
    - Contains sections for Files and Profile (Settings).

### FileListScreen

- **Purpose**: Core functionality for file management.
- **Features**:
    - Displays a list of torrent files.
    - Allows file uploads via a form dialog.
    - Shows user credit balance.
    - Implements pull-to-refresh for updating the file list.

### SettingsScreen

- **Purpose**: Manages user account settings.
- **Features**:
    - Provides a logout option.
    - Clears stored JWT token and credit amount upon logout.

## Models

### FileModel

Represents a torrent file with the following properties:

- `id`: Unique identifier.
- `title`: File name.
- `magnetLink`: Torrent magnet link.
- `size`: File size in bytes.
- `category`: File category (e.g., Movie, Music).
- `uploadDate`: Date of upload.
- `isPurchased`: Purchase status.

Includes a `fromJson` factory method for JSON deserialization.

## Services

### AuthService (FileService)

Handles user authentication:

- **register**: Registers a new user with username, email, and password. Stores JWT token and credit amount in secure storage upon success.
- **login**: Authenticates a user with username and password. Stores JWT token and credit amount in secure storage upon success.

### TorrentManagement

Manages torrent-related operations (details not fully provided).

## Widgets

### FileItem

A custom widget for displaying individual torrent files:

- Displays file details such as title, size, upload date, and category.
- Shows category-specific icons.
- Implements purchase/download functionality with animated state changes.
- Allows copying of magnet links for purchased files.

## Dependencies

Listed in the `pubspec.yaml` file:

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^0.13.3
  flutter_secure_storage: ^9.2.2
  intl: ^0.17.0
  flutter_staggered_grid_view: ^0.7.0
  restart_app: ^1.2.1
  cupertino_icons: ^1.0.6

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
```

## Setup and Installation

1. Ensure Flutter (SDK version >=3.3.3 <4.0.0) is installed.
2. Clone the repository.
3. Run `flutter pub get` to install dependencies.
4. Use `flutter run` to launch the app on a connected device or emulator.

## API Integration

The app communicates with a backend API at `https://mymd.adamdienes.com` for server-side operations including authentication, file listing, and uploads.
