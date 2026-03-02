# Task Management - Flutter Mobile Application

A comprehensive task tracking and management solution built with Flutter and Supabase.

## 🚀 Features
- ✅ User authentication and profile management
- 📝 Create, edit, and delete tasks
- 🏷️ Task categorization and priority levels
- 📊 Task analytics and progress tracking
- 🔔 Real-time notifications
- 📱 Cross-platform support (iOS, Android, Web)
- 🔄 Real-time data synchronization

## 🛠️ Tech Stack
- **Frontend**: Flutter 3.x
- **Backend**: Supabase (PostgreSQL, Auth, Storage)
- **State Management**: Provider/Riverpod
- **Architecture**: Clean Architecture (Feature-first)
- **Testing**: Unit, Widget, and Integration Tests

## 📋 Prerequisites
- Flutter SDK 3.0 or higher
- Dart SDK 2.17 or higher
- Android Studio / VS Code
- Git
- Supabase account

## 🚀 Quick Start

### 1. Clone the Repository
```bash
git clone <repository-url>
cd Task_Management
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Environment Setup
1. Copy the environment file:
   ```bash
   cp .env.example .env
   ```

2. Update `.env` with your Supabase credentials:
   ```
   SUPABASE_URL=your_supabase_project_url
   SUPABASE_ANON_KEY=your_supabase_anon_key
   ```

### 4. Supabase Setup
1. Create a new project at [supabase.com](https://supabase.com)
2. Run the database migration scripts from the `database/` directory:
   - `fix_user_signup_trigger.sql`
   - `check_storage_policies.sql`
   - `fix_storage_policies.sql`
3. Configure authentication providers in Supabase dashboard
4. Set up storage buckets for user avatars and task attachments

### 5. Run the Application
```bash
# Development mode
flutter run

# With specific platform
flutter run -d chrome     # Web
flutter run -d android    # Android
flutter run -d ios        # iOS
```

## 📁 Project Structure
```
lib/
├── core/                   # Core utilities and configurations
│   ├── auth/              # Authentication setup
│   ├── config/            # App configuration
│   └── providers/         # Global providers
├── data/                  # Data layer
│   ├── models/            # Data models
│   ├── repositories/      # Repository implementations
│   └── services/          # External services
├── features/              # Feature modules
│   ├── task_management/   # Task-related features
│   ├── user_profile/      # User profile features
│   └── authentication/    # Authentication features
├── models/               # Shared models
├── screens/              # UI screens
├── widgets/              # Reusable widgets
└── main.dart            # App entry point
```

## 🔧 Development Process

### Phase 1: Environment Setup (Week 1)
1. **Development Environment**
   - Install Flutter SDK and configure IDE
   - Set up version control (Git)
   - Configure code formatting and linting rules

2. **Backend Setup**
   - Create Supabase project
   - Design database schema
   - Set up authentication providers
   - Configure storage buckets

### Phase 2: Architecture & Planning (Week 2)
1. **Project Architecture**
   - Define clean architecture structure
   - Set up state management approach
   - Create project structure and folders

2. **Feature Planning**
   - Define user stories and use cases
   - Create wireframes and mockups
   - Plan API integration points

### Phase 3: Core Development (Weeks 3-6)
1. **Authentication System**
   - User registration and login
   - Password reset functionality
   - Social login integration
   - Session management

2. **Task Management**
   - CRUD operations for tasks
   - Task categorization and filtering
   - Search functionality
   - Task status management

3. **User Profile**
   - Profile creation and editing
   - Avatar upload
   - User preferences
   - Profile settings

### Phase 4: Advanced Features (Weeks 7-8)
1. **Real-time Features**
   - Live task updates
   - Real-time notifications
   - Multi-device synchronization

2. **Analytics & Reporting**
   - Task completion statistics
   - Progress tracking
   - Productivity insights

### Phase 5: Testing & Quality Assurance (Weeks 9-10)
1. **Testing**
   - Unit tests for business logic
   - Widget tests for UI components
   - Integration tests for user flows
   - Performance testing

2. **Code Quality**
   - Code reviews and refactoring
   - Static analysis and linting
   - Documentation updates

## 🧪 Testing

### Run Tests
```bash
# All tests
flutter test

# Specific test file
flutter test test/task_model_test.dart

# Coverage report
flutter test --coverage
```

### Test Categories
- **Unit Tests**: Business logic and models
- **Widget Tests**: UI component testing
- **Integration Tests**: End-to-end user flows

## 📱 Building for Production

### Android
```bash
# Build APK
flutter build apk --release

# Build App Bundle (recommended for Play Store)
flutter build appbundle --release
```

### iOS
```bash
# Build iOS app
flutter build ios --release
```

### Web
```bash
# Build web app
flutter build web --release
```

## 🔍 Debugging

### Common Issues
1. **Emulator Not Starting**: Run `scripts/diagnose_emulator.bat`
2. **Build Errors**: Check `flutter doctor` and update dependencies
3. **Supabase Connection**: Verify environment variables and network connectivity

### Debug Commands
```bash
# Check Flutter environment
flutter doctor -v

# Clean build cache
flutter clean

# Get dependencies
flutter pub get

# Analyze code
flutter analyze
```

## 📚 Additional Documentation
- [Local Setup Guide](LOCAL_SETUP_GUIDE.md)
- [Emulator Setup](EMULATOR_SETUP.md)
- [Firebase Setup](FIREBASE_SETUP.md)
- [Testing Guide](TESTING.md)
- [Architecture Documentation](ARCHITECTURE_README.md)

## 🤝 Contributing
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## 📄 License
This project is licensed under the MIT License - see the LICENSE file for details.

## 📞 Support
For support and questions:
- Create an issue in the repository
- Check the documentation in the `docs/` folder
- Review the troubleshooting guide
