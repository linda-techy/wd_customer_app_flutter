# Customer Portal App (Flutter)

Customer-facing mobile application for viewing project details, payments, site reports, and documents.

## Prerequisites

- Flutter SDK 3.x or higher
- Dart SDK 3.x or higher
- Android Studio / Xcode (for mobile development)
- Access to the Customer API

## Setup

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Configure API Endpoint

Edit `lib/config/api_config.dart`:

```dart
// Local development
static const String localApiUrl = 'http://localhost:8080';

// Production
static const String productionApiUrl = 'https://api.example.com';
```

Or use `.env` files if configured in your project.

### 3. Run the App

```bash
# Run on connected device/emulator
flutter run

# Run in debug mode
flutter run --debug

# Run in release mode
flutter run --release
```

## Security Fixes Applied

### Critical Issues Fixed

✅ **Token Storage Consistency** - Fixed inconsistent token key usage
  - Changed from `'token'` to `'access_token'` in all services
  - Ensures consistent authentication across the app

✅ **Removed Sensitive Debug Logs** - Removed logging of:
  - Email addresses
  - Password lengths
  - Request/response bodies
  - Full error messages with user data

✅ **Improved Error Messages** - User-facing errors no longer expose internal details

### Code Quality Improvements

✅ **Better Error Handling** - Added proper logging in catch blocks
✅ **Consistent Token Access** - All services now use `AuthService.getAccessToken()`

## Security Best Practices

### Do NOT Log Sensitive Data

Never log:
- Authentication tokens
- Passwords or password hints
- Personal information (email, phone)
- Full API request/response bodies

### Use Proper Token Storage

Always use `SharedPreferences` with the key `'access_token'`:

```dart
final prefs = await SharedPreferences.getInstance();
final token = prefs.getString('access_token');
```

Or use `AuthService.getAccessToken()` for consistency.

### Handle Errors Gracefully

Always provide user-friendly error messages without exposing technical details:

```dart
// Good
'Invalid email or password. Please try again.'

// Bad
'Failed to authenticate: JWT signature mismatch for user@example.com'
```

## Development

### Debug Mode

Debug prints are acceptable in development but should:
- Not expose sensitive data
- Be removed or guarded before production release

```dart
if (kDebugMode) {
  debugPrint('Non-sensitive debug info');
}
```

### Code Style

- Use proper error handling (no empty catch blocks)
- Add `mounted` checks before `setState()` in async operations
- Use explicit types where possible
- Follow Flutter best practices

## Building for Production

### Android

```bash
flutter build apk --release
# or
flutter build appbundle --release
```

### iOS

```bash
flutter build ios --release
```

### Before Release

- [ ] Remove all sensitive debug logs
- [ ] Test authentication flow thoroughly
- [ ] Verify API endpoint configuration
- [ ] Test on multiple devices/screen sizes
- [ ] Run `flutter analyze` and fix warnings
- [ ] Test offline behavior

## Troubleshooting

### Authentication Issues

If users can't log in:
1. Verify API endpoint is correct and accessible
2. Check token storage key is `'access_token'`
3. Ensure API is running and healthy
4. Check network connectivity

### Token Refresh Issues

If token refresh fails:
1. Verify refresh token is stored correctly
2. Check token expiration settings match API
3. Ensure API refresh endpoint is working

## Related Projects

- **Customer API**: Backend API for this app
- **Portal App**: Internal admin/staff application

## Security

For security guidelines and incident response, see the Customer API's SECURITY.md file.
