import Foundation

@Observable
final class MemoryViewModel {
    var memories: [Memory] = []
    var isLoading = false
    var searchQuery = ""
    var selectedLevel: Int?
    var error: String?

    private let userId: String

    init(userId: String) {
        self.userId = userId
    }

    func load() async {
        isLoading = true
        do {
            memories = try await MemoryService.list(userId: userId, level: selectedLevel)
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    func search() async {
        guard !searchQuery.trimmingCharacters(in: .whitespaces).isEmpty else {
            await load()
            return
        }
        isLoading = true
        do {
            memories = try await MemoryService.search(userId: userId, query: searchQuery)
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    func filterByLevel(_ level: Int?) async {
        selectedLevel = level
        await load()
    }
}
