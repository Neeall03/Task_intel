import Foundation

struct Lesson: Identifiable, Codable, Equatable {
    let id: Int
    let title: String
    var isCompleted: Bool
}

struct Course: Identifiable, Codable, Equatable {
    let id: Int
    let title: String
    let instructor: String
    var lessons: [Lesson]

    var progress: Int {
        guard !lessons.isEmpty else { return 0 }
        let completedCount = lessons.filter(\.isCompleted).count
        return Int((Double(completedCount) / Double(lessons.count) * 100).rounded())
    }

    static let samples = [
         sample(1, "Python Programming", "John Smith", 20, 13,
             ["Introduction", "Variables & Data Types", "Functions", "Object-Oriented Programming"]),
         sample(2, "Generative AI", "Sarah Williams", 15, 6,
             ["Introduction to Generative AI", "Prompting Fundamentals", "Working with Models", "Responsible AI"]),
         sample(3, "Full Stack Development", "David Brown", 28, 7,
             ["Web Foundations", "HTML & CSS", "JavaScript", "Building APIs"])
    ]

        private static func sample(_ id: Int, _ title: String, _ instructor: String, _ count: Int, _ completed: Int, _ topics: [String]) -> Course {
        let lessons = (0..<count).map { index in
             let title = index < topics.count ? topics[index] : "Lesson \(index + 1)"
             return Lesson(id: index + 1, title: title, isCompleted: index < completed)
        }
        return Course(id: id, title: title, instructor: instructor, lessons: lessons)
    }
}
