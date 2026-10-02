import Foundation

protocol AuthenticationService {
    func login(email: String, password: String) async throws
}

struct MockAuthenticationService: AuthenticationService {
    func login(email: String, password: String) async throws {
        try await Task.sleep(for: .milliseconds(550))
        if email.lowercased() == "error@example.com" { throw LoginError.rejected }
    }
}

enum LoginError: LocalizedError {
    case rejected

    var errorDescription: String? {
        "We couldn't sign you in. Check your details and try again."
    }
}
