import SwiftUI

struct CourseRow: View {
    let course: Course

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(course.title)
                        .font(.system(.title3, design: .serif).weight(.semibold))
                        .foregroundStyle(.primary)
                    Text("WITH \(course.instructor.uppercased())")
                        .font(.caption2.weight(.medium)).tracking(0.7)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "arrow.up.right")
                    .font(.caption.weight(.semibold)).foregroundStyle(.secondary)
            }
            ProgressView(value: Double(course.progress), total: 100)
                .tint(Color(red: 0.13, green: 0.39, blue: 0.34))
            HStack {
                Text("\(course.progress)% complete").font(.caption.weight(.medium))
                Spacer()
                Text("\(course.lessons.count) lessons")
                    .font(.caption).foregroundStyle(.secondary)
                Text("Continue")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color(red: 0.13, green: 0.39, blue: 0.34))
            }
        }
        .padding(.vertical, 12).contentShape(Rectangle())
    }
}
