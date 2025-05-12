# MQTT Flutter App with Data Download and Persistence

## Overview

This Flutter application demonstrates a simple MQTT client with the ability to:

1. Connect to an MQTT broker
2. Subscribe to topics
3. Send and receive messages
4. Download and persist large datasets using Dart isolates
5. Display paginated data with infinite scrolling

The app follows clean architecture principles and uses BLoC pattern for state management. It's designed to be beginner-friendly for those learning Flutter and BLoC.

## Features

### MQTT Client
- Connect to a public MQTT broker (test.mosquitto.org)
- Subscribe/unsubscribe to topics
- Send messages to topics
- Receive and display messages

### Data Download (triggered by 'download' keyword)
- Simulates downloading 50,000+ records using Dart isolates
- Shows real-time download progress
- Persists data using ISAR database
- Supports paginated viewing with infinite scrolling

## How to Use

### MQTT Functionality
1. Open the app and it will automatically connect to the MQTT broker
2. Enter a topic name in the text field (default: "test/topic")
3. Tap "Subscribe" to subscribe to the topic
4. Once subscribed, you can send messages using the text field at the bottom
5. Received messages will appear in the list

### Data Download Feature
1. Send a message containing the word "download"
2. A download button will appear in the header
3. Tap the button to navigate to the Data Download screen
4. Tap "Download Data" to start the simulated download
5. The app will show progress while downloading
6. Once complete, data will be displayed in a paginated list
7. Scroll to the bottom to load more records

### Data Persistence
- Downloaded data is stored in ISAR database
- Data remains available after app restart
- Use the "Clear Records" button to delete all stored data

## Implementation Details

- **Architecture**: Clean Architecture
- **State Management**: BLoC pattern using flutter_bloc
- **Database**: ISAR for local storage
- **Concurrency**: Dart isolates for background processing
- **UI**: Material Design with responsive layouts

## Project Structure

```
lib/
├── app.dart                # App entry point
├── main.dart               # Main file with flavor support
├── core/                   # Core functionality
│   ├── services/           # Common services
│   └── theme/              # App theme
└── features/               # Feature modules
    ├── mqtt_client/        # MQTT client feature
    │   ├── data/           # Data layer
    │   └── presentation/   # UI layer
    └── data_download/      # Data download feature
        ├── data/           # Data layer with ISAR models
        └── presentation/   # UI layer
```

## Getting Started

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Run `flutter run --flavor cowlar_dev` to start the app in development mode