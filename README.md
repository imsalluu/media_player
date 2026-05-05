# Media Player - Offline Video & Audio Player

A premium, full-featured offline media player built with Flutter. This app scans your device for local media files and provides a smooth, modern experience for both audio and video playback.

## 🚀 Features

### 🎬 Video Player
- **High Performance**: Smooth playback of high-res videos.
- **Controls**: Play/Pause, Seek, Forward/Rewind (10s), and Fullscreen mode.
- **Thumbnails**: Instant video thumbnails for easy browsing.
- **Auto-Rotate**: Full support for landscape and portrait modes.

### 🎵 Audio Player
- **Background Play**: Keep listening even when the app is minimized.
- **Advanced Controls**: Shuffle, Repeat, Next/Previous.
- **Rich Metadata**: Displays title, artist, and album information.
- **Progress Control**: Interactive seek bar with real-time progress.

### 📁 Media Library
- **Smart Scanning**: Fetches all local audio and video files.
- **Search & Filter**: Find your media instantly with real-time search.
- **Deep Sorting**: Sort by name, date added, or file size.
- **Favorites**: Mark your favorite media for quick access.
- **Recently Played**: Keeps track of your playback history.

## 🛠️ Built With

- **Flutter**: Cross-platform framework.
- **Riverpod**: State management for a robust architecture.
- **just_audio**: High-quality audio playback engine.
- **video_player & Chewie**: Powerful video playback with full controls.
- **on_audio_query**: For rich music metadata scanning.
- **photo_manager**: Efficient local media fetching.

## 📱 Getting Started

### Prerequisites
- Flutter SDK (3.x or latest)
- Android Studio / VS Code
- A physical Android device (recommended for media storage access)

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/media_player.git
   ```
2. Navigate to the project directory:
   ```bash
   cd media_player
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   flutter run
   ```

## 🔐 Permissions
The app requires the following permissions:
- `READ_EXTERNAL_STORAGE` (Android 10 and below)
- `READ_MEDIA_AUDIO` & `READ_MEDIA_VIDEO` (Android 13+)
- `FOREGROUND_SERVICE` (For background audio playback)

## 🎨 UI/UX
- **Material 3 Design**: Modern, clean, and intuitive.
- **Dark Mode Support**: Automatically matches your system theme.
- **Glassmorphism Elements**: Premium feel with subtle gradients and blurs.

## 📄 License
This project is licensed under the MIT License - see the LICENSE file for details.
