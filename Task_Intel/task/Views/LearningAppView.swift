import SwiftUI

struct LearningAppView: View {
    @StateObject private var authentication = AuthenticationViewModel()
    @StateObject private var learning = LearningViewModel()

    var body: some View {
        Group {
            if authentication.isAuthenticated {
                CourseListView(viewModel: learning)
            } else {
                LoginView(viewModel: authentication)
            }
        }
        .tint(Color(red: 0.13, green: 0.39, blue: 0.34))
    }
}
