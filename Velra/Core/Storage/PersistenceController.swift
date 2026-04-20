import Foundation
import SwiftData

@MainActor
final class PersistenceController: Sendable {
    static let shared = PersistenceController()

    let modelContainer: ModelContainer

    private init() {
        let schema = Schema([
            CartItemModel.self
        ])

        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true
        )

        do {
            modelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Failed to create ModelContainer: \(error.localizedDescription)")
        }
    }

    static func createPreviewContainer() -> ModelContainer {
        let schema = Schema([
            CartItemModel.self
        ])

        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )

        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Failed to create preview ModelContainer: \(error.localizedDescription)")
        }
    }
}
