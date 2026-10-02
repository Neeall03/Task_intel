import SwiftUI

struct LoginView: View {
    @ObservedObject var viewModel: AuthenticationViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var validationMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Spacer()
            VStack(alignment: .leading, spacing: 8) {
                Text("FIELDNOTES").font(.caption.weight(.bold)).tracking(1.8)
                    .foregroundStyle(.secondary)
                Text("Make room\nto learn.")
                    .font(.system(size: 42, weight: .semibold, design: .serif))
                    .lineSpacing(-5)
            }
            VStack(spacing: 14) {
                TextField("Email", text: $email)
                    .textContentType(.emailAddress).keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never).autocorrectionDisabled()
                    .textFieldStyle(.roundedBorder).accessibilityIdentifier("login.email")
                SecureField("Password", text: $password)
                    .textContentType(.password).textFieldStyle(.roundedBorder)
                    .accessibilityIdentifier("login.password")
            }
            if let message = validationMessage ?? viewModel.errorMessage {
                Text(message).font(.footnote).foregroundStyle(.red)
                    .accessibilityIdentifier("login.error")
            }
            Button(action: submit) {
                HStack {
                    Spacer()
                    if viewModel.isLoggingIn { ProgressView().tint(.white) }
                    else { Text("Log in").fontWeight(.semibold) }
                    Spacer()
                }
                .frame(height: 50)
                .background(Color(red: 0.13, green: 0.39, blue: 0.34))
                .foregroundStyle(.white).clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .disabled(viewModel.isLoggingIn).accessibilityIdentifier("login.submit")
            Spacer()
            Text("Your next chapter starts here.")
                .font(.footnote).foregroundStyle(.secondary)
        }
        .padding(28)
        .background(Color(red: 0.97, green: 0.96, blue: 0.92).ignoresSafeArea())
    }

    private func submit() {
        validationMessage = nil
        guard email.contains("@"), email.split(separator: "@").last?.contains(".") == true else {
            validationMessage = "Enter a valid email address."
            return
        }
        guard password.count >= 6 else {
            validationMessage = "Password must be at least 6 characters."
            return
        }
        Task { await viewModel.login(email: email, password: password) }
    }
}
