import Foundation

protocol CourseService {
    func fetchCourses() async throws -> [Course]
}

struct MockCourseService: CourseService {
    func fetchCourses() async throws -> [Course] {
        try await Task.sleep(for: .milliseconds(450))
        return Course.samples
    }
}
