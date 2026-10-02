# Learning Dashboard

## Architecture
The app follows MVVM with SwiftUI views, main-actor observable view models, and a repository for course data access. Authentication and course loading are separate flows: `AuthenticationViewModel` uses `AuthenticationService`, while `LearningViewModel` uses `CourseRepository`.

Source responsibilities:
- `task/Models`: course and lesson data, including progress calculation.
- `task/Views`: login, course list, and detail screens; reusable rows are in `Views/Components`.
- `task/ViewModels`: authentication and learning screen state and actions.
- `task/Repositories`: course loading, cache fallback, and persistence coordination.
- `task/Services`: authentication and course-fetching interfaces and mock implementations.

Keep Swift files below 80 lines. Split reusable UI into small components when a view approaches that limit.

## Offline support
Successful course loads and lesson updates are encoded as JSON in the app's Documents directory. If course loading fails, the repository returns the last saved copy and the dashboard indicates offline mode. With no cache, the dashboard shows an error and retry action.

The app delegate still contains the Xcode Core Data template, but course data is stored by the JSON cache rather than Core Data.

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
