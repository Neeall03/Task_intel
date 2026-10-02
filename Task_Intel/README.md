# Learning Dashboard

## Architecture
The app uses SwiftUI views backed by a main-actor observable view model, which delegates course loading and persistence to a repository. The repository keeps the mock service and local cache behind protocols so either dependency can be replaced in tests or in production.

## Offline support
Successful course loads and lesson updates are encoded as JSON in the app's Documents directory. If course loading fails, the repository returns the last saved copy and the dashboard indicates offline mode. With no cache, the dashboard shows an error and retry action.

## Security
Production authentication tokens belong in the iOS Keychain, with appropriate access controls. This assignment uses mock authentication and stores no token.

## Scale
- Replace the mock service with a paginated, authenticated API and add request timeouts/retries.
- Add database-backed persistence, schema migration, and explicit conflict handling for offline edits.
- Use pagination and incremental loading for large course catalogs.
- Add observability, crash reporting, and automated API/contract tests.

## Android implementation
I would use Kotlin with Jetpack Compose, a ViewModel and StateFlow for screen state, a repository over Retrofit/Ktor and Room, and encrypted Android Keystore-backed token storage. Compose Navigation would provide the login, dashboard, and course-detail flow.

## Running
Open `task.xcodeproj` in Xcode and run the `task` scheme on an iOS 17 or later simulator. Use any valid email and a password of at least six characters; `error@example.com` demonstrates the mock login error.