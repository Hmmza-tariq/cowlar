# Cowlar Flutter App

A Flutter application built with clean architecture principles and BLoC state management.

## Project Structure

This project follows the clean architecture pattern with the following structure:

```
lib/
  ├── core/                   # Core functionality used across the app
  │   ├── bloc/               # Global bloc related files
  │   ├── config/             # Configuration files
  │   ├── constants/          # App constants
  │   ├── di/                 # Dependency injection
  │   ├── errors/             # Error handling
  │   ├── network/            # Network related code
  │   ├── theme/              # App theme
  │   ├── utils/              # Utility functions
  │   └── widgets/            # Shared widgets
  │
  ├── features/               # App features organized by domain
  │   └── home/               # Home feature
  │       ├── data/           # Data layer
  │       │   ├── datasources/  # Data sources
  │       │   ├── models/       # Data models
  │       │   └── repositories/ # Repository implementations
  │       │
  │       ├── domain/         # Domain layer
  │       │   ├── entities/     # Domain entities
  │       │   ├── repositories/ # Repository interfaces
  │       │   └── usecases/     # Use cases
  │       │
  │       └── presentation/   # Presentation layer
  │           ├── bloc/         # BLoCs
  │           ├── pages/        # Pages
  │           └── widgets/      # Widgets
  │
  ├── app.dart               # App configuration
  ├── flavors.dart           # Flavor configuration
  └── main.dart              # Entry point
```

## Flavors

This app supports three flavors:
- Development (`cowlar_dev`)
- Staging (`cowlar_stage`)
- Production (`cowlar_prod`)

### Running Different Flavors

To run the app with a specific flavor:

```bash
# Development
flutter run --flavor cowlar_dev -t lib/main_dev.dart

# Staging
flutter run --flavor cowlar_stage -t lib/main_stage.dart

# Production
flutter run --flavor cowlar_prod -t lib/main_prod.dart
```

## State Management

This app uses BLoC (Business Logic Component) pattern for state management. Key benefits:

- Separation of concerns
- Testability
- Predictable state changes
- Reactive programming approach

## Dependencies

- `flutter_bloc` & `bloc`: State management
- `equatable`: Value equality
- `get_it`: Dependency injection
- `dartz`: Functional programming
- `dio`: HTTP client
- `shared_preferences`: Local storage
