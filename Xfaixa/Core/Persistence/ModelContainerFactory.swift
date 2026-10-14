import Foundation
import OSLog
import SwiftData

/// Builds the SwiftData container shared by every feature that persists data.
enum ModelContainerFactory {
    private static let logger = Logger(subsystem: "devpedrovillalba.Xfaixa", category: "Persistence")

    static func make(inMemory: Bool = false) -> ModelContainer {
        do {
            return try ModelContainer(
                for: FavoriteSong.self,
                configurations: ModelConfiguration(isStoredInMemoryOnly: inMemory)
            )
        } catch {
            // A corrupted or incompatible store shouldn't brick the app: start fresh in memory instead.
            logger.error("Falling back to an in-memory store: \(error.localizedDescription)")
            do {
                return try ModelContainer(for: FavoriteSong.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
            } catch {
                fatalError("Unable to create even an in-memory ModelContainer: \(error)")
            }
        }
    }
}
