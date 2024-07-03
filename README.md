# Budget Tracker App

## Description

Budget Tracker is a Flutter-based mobile application designed to help users manage their personal finances. It allows users to track their income and expenses, view their budget history, and manage their financial data efficiently.

## Features

- Add and manage income and expense entries
- Categorize entries (income/expense)
- View monthly summaries of financial activities
- Export financial data as JSON
- Import financial data from JSON files
- Reset all data and start fresh
- Cross-platform support (iOS and Android)

## Technologies Used

- Flutter
- Dart
- Hive (for local data storage)
- path_provider (for accessing device file system)
- file_picker (for Android file selection)
- intl (for date formatting)
- shared_preferences (for app settings)

## Getting Started

### Prerequisites

- Flutter SDK
- Dart SDK
- Android Studio or Xcode (for running on emulators/simulators)

### Installation

1. Clone the repository:
   ```
   git clone https://github.com/your-username/budget-tracker-app.git
   ```

2. Navigate to the project directory:
   ```
   cd budget-tracker-app
   ```

3. Install dependencies:
   ```
   flutter pub get
   ```

4. Run the app:
   ```
   flutter run
   ```

## Usage

- **Adding Entries**: Tap the '+' button to add a new income or expense entry.
- **Viewing History**: Scroll through the main screen to view your financial history, organized by month.
- **Exporting Data**: Go to Settings > Export Data to save your financial data as a JSON file.
- **Importing Data**: Go to Settings > Import Data to load previously exported data.
- **Resetting Data**: Go to Settings > Reset All Data to clear all entries and start fresh.

## Platform-Specific Notes

### iOS
- For exporting, the app saves files to the app's documents directory. Users can access these files via the Files app.
- For importing, users need to manually move the JSON file to the app's directory using the Files app before importing within the app.

### Android
- File picking for both import and export is handled natively using the file_picker package.

## Contributing

Contributions to improve Budget Tracker are welcome. Please follow these steps:

1. Fork the repository
2. Create a new branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

Distributed under the MIT License. See `LICENSE` file for more information.

## Contact

Your Name - your.email@example.com

Project Link: [https://github.com/your-username/budget-tracker-app](https://github.com/your-username/budget-tracker-app)

## Acknowledgements

- [Flutter](https://flutter.dev)
- [Hive](https://pub.dev/packages/hive)
- [file_picker](https://pub.dev/packages/file_picker)
- [path_provider](https://pub.dev/packages/path_provider)
- [intl](https://pub.dev/packages/intl)
- [shared_preferences](https://pub.dev/packages/shared_preferences)