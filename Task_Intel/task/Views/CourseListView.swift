import SwiftUI

struct CourseListView: View {
    @ObservedObject var viewModel: LearningViewModel

    var body: some View {
        NavigationStack {
            content
                .background(Color(red: 0.97, green: 0.96, blue: 0.92))
                .navigationTitle("Your learning")
                .navigationBarTitleDisplayMode(.large)
                .toolbar { offlineIndicator }
                .navigationDestination(for: Int.self) { courseID in
                    CourseDetailView(courseID: courseID, viewModel: viewModel)
                }
        }
        .task {
            if viewModel.courses.isEmpty { await viewModel.loadCourses() }
        }
    }

    @ViewBuilder private var content: some View {
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
            ContentUnavailableView("No courses yet", systemImage: "books.vertical")
        } else {
            List(viewModel.courses) { course in
                NavigationLink(value: course.id) { CourseRow(course: course) }
                    .listRowSeparator(.hidden).listRowBackground(Color.clear)
                    .accessibilityIdentifier("course.\(course.id)")
            }
            .listStyle(.plain).refreshable { await viewModel.loadCourses() }
        }
    }

    @ToolbarContentBuilder private var offlineIndicator: some ToolbarContent {
        if viewModel.isOffline {
            ToolbarItem(placement: .topBarTrailing) {
                Label("Offline", systemImage: "icloud.slash")
                    .font(.caption.weight(.medium))
                    .accessibilityIdentifier("dashboard.offline")
            }
        }
    }
}
