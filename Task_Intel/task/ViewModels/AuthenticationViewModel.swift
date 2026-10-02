import Combine
import Foundation

@MainActor
final class AuthenticationViewModel: ObservableObject {
    @Published private(set) var isAuthenticated = false
    @Published private(set) var isLoggingIn = false
    @Published private(set) var errorMessage: String?

    private let service: any AuthenticationService

    init(service: (any AuthenticationService)? = nil) {
        self.service = service ?? MockAuthenticationService()
    }

    func login(email: String, password: String) async {
        errorMessage = nil
        isLoggingIn = true
        defer { isLoggingIn = false }
        do {
            try await service.login(email: email, password: password)
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
