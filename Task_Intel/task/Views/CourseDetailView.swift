import SwiftUI

struct CourseDetailView: View {
    let courseID: Int
    @ObservedObject var viewModel: LearningViewModel
    private var course: Course? { viewModel.courses.first { $0.id == courseID } }

    var body: some View {
        Group {
            if let course {
                List {
                    Section {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(course.instructor).font(.subheadline).foregroundStyle(.secondary)
                            HStack {
                                Text("Course progress")
                                Spacer()
                                Text("\(course.progress)%").fontWeight(.semibold)
                                    .accessibilityIdentifier("course.progress")
                            }
                            ProgressView(value: Double(course.progress), total: 100)
                        }
                        .padding(.vertical, 6)
                    }
                    Section("LESSONS") {
                        ForEach(course.lessons) { lesson in
                            LessonRow(lesson: lesson) {
                                viewModel.toggleLesson(courseID: courseID, lessonID: lesson.id)
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped).navigationTitle(course.title)
                .navigationBarTitleDisplayMode(.inline)
            } else {
                ContentUnavailableView("Course unavailable", systemImage: "book.closed")
            }
        }
    }
}
