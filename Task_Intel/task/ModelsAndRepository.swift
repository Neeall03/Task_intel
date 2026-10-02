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
        return Int((Double(lessons.filter(\.isCompleted).count) / Double(lessons.count) * 100).rounded())
    }

    static let samples: [Course] = [
        Course(id: 1, title: "Python Programming", instructor: "John Smith", lessons: makeLessons(count: 20, completed: 13, topics: ["Introduction", "Variables & Data Types", "Functions", "Object-Oriented Programming"])),
        Course(id: 2, title: "Generative AI", instructor: "Sarah Williams", lessons: makeLessons(count: 15, completed: 6, topics: ["Introduction to Generative AI", "Prompting Fundamentals", "Working with Models", "Responsible AI"])),
        Course(id: 3, title: "Full Stack Development", instructor: "David Brown", lessons: makeLessons(count: 28, completed: 7, topics: ["Web Foundations", "HTML & CSS", "JavaScript", "Building APIs"]))
    ]

    private static func makeLessons(count: Int, completed: Int, topics: [String]) -> [Lesson] {
        (0..<count).map { index in
            Lesson(
                id: index + 1,
                title: index < topics.count ? topics[index] : "Lesson \(index + 1)",
                isCompleted: index < completed
            )
        }
    }
}

protocol CourseService {
    func fetchCourses() async throws -> [Course]
}

struct MockCourseService: CourseService {
    func fetchCourses() async throws -> [Course] {
        try await Task.sleep(for: .milliseconds(450))
        return Course.samples
    }
}

protocol CourseCache {
    func load() throws -> [Course]?
    func save(_ courses: [Course]) throws
}

struct JSONCourseCache: CourseCache {
    private let fileURL: URL

    init(fileURL: URL? = nil) {
        self.fileURL = fileURL ?? FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("courses.json")
    }

    func load() throws -> [Course]? {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return nil }
        return try JSONDecoder().decode([Course].self, from: Data(contentsOf: fileURL))
    }

    func save(_ courses: [Course]) throws {
        let data = try JSONEncoder().encode(courses)
        try data.write(to: fileURL, options: .atomic)
    }
}

struct CourseRepository {
    private let service: any CourseService
    private let cache: any CourseCache

    init(service: any CourseService = MockCourseService(), cache: any CourseCache = JSONCourseCache()) {
        self.service = service
        self.cache = cache
    }

    func loadCourses() async throws -> (courses: [Course], isOffline: Bool) {
        let fetchedCourses: [Course]
        do {
            fetchedCourses = try await service.fetchCourses()
        } catch {
            if let cachedCourses = try cache.load() {
                return (cachedCourses, true)
            }
            throw error
        }

        let cachedCourses = (try? cache.load()) ?? nil
        let courses = fetchedCourses.map { fetchedCourse in
            guard let cachedCourse = cachedCourses?.first(where: { $0.id == fetchedCourse.id }) else {
                return fetchedCourse
            }
            let completionByLessonID = Dictionary(uniqueKeysWithValues: cachedCourse.lessons.map { ($0.id, $0.isCompleted) })
            var refreshedCourse = fetchedCourse
            refreshedCourse.lessons = fetchedCourse.lessons.map { lesson in
                var refreshedLesson = lesson
                refreshedLesson.isCompleted = completionByLessonID[lesson.id] ?? lesson.isCompleted
                return refreshedLesson
            }
            return refreshedCourse
        }
        try cache.save(courses)
        return (courses, false)
    }

    func save(_ courses: [Course]) throws {
        try cache.save(courses)
    }
}

enum LoginError: LocalizedError {
    case rejected

    var errorDescription: String? {
        "We couldn't sign you in. Check your details and try again."
    }
}

struct MockAuthenticationService {
    func login(email: String, password: String) async throws {
        try await Task.sleep(for: .milliseconds(550))
        if email.lowercased() == "error@example.com" {
            throw LoginError.rejected
        }
    }
}