import SwiftUI

struct LearningAppView: View {
    @StateObject private var viewModel = LearningViewModel()

    var body: some View {
        Group {
            if viewModel.isAuthenticated {
                CourseListView(viewModel: viewModel)
            } else {
                LoginView(viewModel: viewModel)
            }
        }
        .tint(Color(red: 0.13, green: 0.39, blue: 0.34))
    }
}

private struct LoginView: View {
    @ObservedObject var viewModel: LearningViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var validationMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Spacer()
            VStack(alignment: .leading, spacing: 8) {
                Text("FIELDNOTES")
                    .font(.caption.weight(.bold))
                    .tracking(1.8)
                    .foregroundStyle(.secondary)
                Text("Make room\nto learn.")
                    .font(.system(size: 42, weight: .semibold, design: .serif))
                    .lineSpacing(-5)
            }
            VStack(spacing: 14) {
                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .textFieldStyle(.roundedBorder)
                    .accessibilityIdentifier("login.email")
                SecureField("Password", text: $password)
                    .textContentType(.password)
                    .textFieldStyle(.roundedBorder)
                    .accessibilityIdentifier("login.password")
            }
            if let message = validationMessage ?? viewModel.loginError {
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .accessibilityIdentifier("login.error")
            }
            Button(action: submit) {
                HStack {
                    Spacer()
                    if viewModel.isLoggingIn {
                        ProgressView().tint(.white)
                    } else {
                        Text("Log in").fontWeight(.semibold)
                    }
                    Spacer()
                }
                .frame(height: 50)
                .background(Color(red: 0.13, green: 0.39, blue: 0.34))
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .disabled(viewModel.isLoggingIn)
            .accessibilityIdentifier("login.submit")
            Spacer()
            Text("Your next chapter starts here.")
                .font(.footnote)
                .foregroundStyle(.secondary)
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

private struct CourseListView: View {
    @ObservedObject var viewModel: LearningViewModel

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.courses.isEmpty {
                    ProgressView("Loading courses…")
                } else if let error = viewModel.errorMessage, viewModel.courses.isEmpty {
                    ContentUnavailableView {
                        Label("Couldn't load courses", systemImage: "wifi.exclamationmark")
                    } description: {
                        Text(error)
                    } actions: {
                        Button("Try again") { Task { await viewModel.loadCourses() } }
                    }
                } else if viewModel.courses.isEmpty {
                    ContentUnavailableView("No courses yet", systemImage: "books.vertical", description: Text("Your courses will appear here."))
                } else {
                    List(viewModel.courses) { course in
                        NavigationLink(value: course.id) {
                            CourseRow(course: course)
                        }
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .accessibilityIdentifier("course.\(course.id)")
                    }
                    .listStyle(.plain)
                    .refreshable { await viewModel.loadCourses() }
                }
            }
            .background(Color(red: 0.97, green: 0.96, blue: 0.92))
            .navigationTitle("Your learning")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                if viewModel.isOffline {
                    ToolbarItem(placement: .topBarTrailing) {
                        Label("Offline", systemImage: "icloud.slash")
                            .font(.caption.weight(.medium))
                            .accessibilityIdentifier("dashboard.offline")
                    }
                }
            }
            .navigationDestination(for: Int.self) { courseID in
                CourseDetailView(courseID: courseID, viewModel: viewModel)
            }
        }
        .task {
            if viewModel.courses.isEmpty { await viewModel.loadCourses() }
        }
    }
}

private struct CourseRow: View {
    let course: Course

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(course.title)
                        .font(.system(.title3, design: .serif).weight(.semibold))
                        .foregroundStyle(.primary)
                    Text("WITH \(course.instructor.uppercased())")
                        .font(.caption2.weight(.medium))
                        .tracking(0.7)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "arrow.up.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            ProgressView(value: Double(course.progress), total: 100)
                .tint(Color(red: 0.13, green: 0.39, blue: 0.34))
            HStack {
                Text("\(course.progress)% complete")
                    .font(.caption.weight(.medium))
                Spacer()
                Text("\(course.lessons.count) lessons")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("Continue")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color(red: 0.13, green: 0.39, blue: 0.34))
            }
        }
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}

private struct CourseDetailView: View {
    let courseID: Int
    @ObservedObject var viewModel: LearningViewModel

    private var course: Course? { viewModel.courses.first { $0.id == courseID } }

    var body: some View {
        Group {
            if let course {
                List {
                    Section {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(course.instructor)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            HStack {
                                Text("Course progress")
                                Spacer()
                                Text("\(course.progress)%")
                                    .fontWeight(.semibold)
                                    .accessibilityIdentifier("course.progress")
                            }
                            ProgressView(value: Double(course.progress), total: 100)
                        }
                        .padding(.vertical, 6)
                    }
                    Section("LESSONS") {
                        ForEach(course.lessons) { lesson in
                            Button {
                                viewModel.toggleLesson(courseID: courseID, lessonID: lesson.id)
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: lesson.isCompleted ? "checkmark.circle.fill" : "circle")
                                        .foregroundStyle(lesson.isCompleted ? Color(red: 0.13, green: 0.39, blue: 0.34) : .secondary)
                                    Text(lesson.title)
                                        .foregroundStyle(.primary)
                                    Spacer()
                                    Text(lesson.isCompleted ? "Completed" : "Mark done")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier("lesson.\(lesson.id)")
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .navigationTitle(course.title)
                .navigationBarTitleDisplayMode(.inline)
            } else {
                ContentUnavailableView("Course unavailable", systemImage: "book.closed")
            }
        }
    }
}