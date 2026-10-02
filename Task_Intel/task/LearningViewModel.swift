import Combine
import Foundation

@MainActor
final class LearningViewModel: ObservableObject {
    @Published var courses: [Course] = []
    @Published var isLoading = false
    @Published var isOffline = false
    @Published var errorMessage: String?
    @Published var isAuthenticated = false
    @Published var isLoggingIn = false
    @Published var loginError: String?

    private let repository: CourseRepository
    private let authenticationService: MockAuthenticationService

    init(repository: CourseRepository? = nil, authenticationService: MockAuthenticationService? = nil) {
        self.repository = repository ?? CourseRepository()
        self.authenticationService = authenticationService ?? MockAuthenticationService()
    }

    func login(email: String, password: String) async {
        loginError = nil
        isLoggingIn = true
        defer { isLoggingIn = false }
        do {
            try await authenticationService.login(email: email, password: password)
            isAuthenticated = true
            await loadCourses()
        } catch {
            loginError = error.localizedDescription
        }
    }

    func loadCourses() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            let result = try await repository.loadCourses()
            courses = result.courses
            isOffline = result.isOffline
        } catch {
            errorMessage = "Courses couldn't be loaded. Please try again."
        }
    }

    func toggleLesson(courseID: Int, lessonID: Int) {
        guard let courseIndex = courses.firstIndex(where: { $0.id == courseID }),
              let lessonIndex = courses[courseIndex].lessons.firstIndex(where: { $0.id == lessonID }) else { return }
        courses[courseIndex].lessons[lessonIndex].isCompleted.toggle()
        do {
            try repository.save(courses)
        } catch {
            errorMessage = "Your progress couldn't be saved on this device."
        }
    }
}