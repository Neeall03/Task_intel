import XCTest
@testable import task

final class taskTests: XCTestCase {
    func testCompletingLessonUpdatesCourseProgress() {
        let lessons = [
            Lesson(id: 1, title: "One", isCompleted: true),
            Lesson(id: 2, title: "Two", isCompleted: false),
            Lesson(id: 3, title: "Three", isCompleted: false),
            Lesson(id: 4, title: "Four", isCompleted: false)
        ]
        var course = Course(id: 1, title: "Course", instructor: "Instructor", lessons: lessons)

        XCTAssertEqual(course.progress, 25)
        course.lessons[1].isCompleted = true
        XCTAssertEqual(course.progress, 50)
    }

    @MainActor
    func testRepositoryFallsBackToCacheAndPreservesProgressOnRefresh() async throws {
        var cachedCourse = Course.samples[0]
        cachedCourse.lessons[19].isCompleted = true
        let cacheURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("json")
        let cache = JSONCourseCache(fileURL: cacheURL)
        defer { try? FileManager.default.removeItem(at: cacheURL) }
        try cache.save([cachedCourse])

        let offlineResult = try await CourseRepository(service: OfflineCourseService(), cache: cache).loadCourses()
        XCTAssertTrue(offlineResult.isOffline)
        XCTAssertEqual(offlineResult.courses[0].progress, 70)

        let refreshedResult = try await CourseRepository(service: MockCourseService(), cache: cache).loadCourses()
        XCTAssertFalse(refreshedResult.isOffline)
        XCTAssertTrue(refreshedResult.courses[0].lessons[19].isCompleted)
    }
}

@MainActor
private struct OfflineCourseService: CourseService {
    func fetchCourses() async throws -> [Course] {
        throw URLError(.notConnectedToInternet)
    }
}