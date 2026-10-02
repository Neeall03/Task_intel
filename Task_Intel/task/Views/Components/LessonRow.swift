import SwiftUI

struct LessonRow: View {
    let lesson: Lesson
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                Image(systemName: lesson.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(lesson.isCompleted ? Color(red: 0.13, green: 0.39, blue: 0.34) : .secondary)
                Text(lesson.title).foregroundStyle(.primary)
                Spacer()
                Text(lesson.isCompleted ? "Completed" : "Mark done")
                    .font(.caption).foregroundStyle(.secondary)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain).accessibilityIdentifier("lesson.\(lesson.id)")
    }
}
