import Foundation

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
            if let cachedCourses = try cache.load() { return (cachedCourses, true) }
            throw error
        }
        let cachedCourses = (try? cache.load()) ?? nil
        let courses = fetchedCourses.map { course in
            var refreshed = course
            let savedLessons = cachedCourses?.first { $0.id == course.id }?.lessons ?? []
            let completion = Dictionary(uniqueKeysWithValues: savedLessons.map { ($0.id, $0.isCompleted) })
            refreshed.lessons = course.lessons.map { lesson in
                var updated = lesson
                updated.isCompleted = completion[lesson.id] ?? lesson.isCompleted
                return updated
            }
            return refreshed
        }
        try cache.save(courses)
        return (courses, false)
    }

    func save(_ courses: [Course]) throws {
        try cache.save(courses)
    }
}
