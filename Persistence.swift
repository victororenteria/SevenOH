import Foundation
import SwiftData

/// A shared model container used by both the main app and the widget.
struct Persistence {
    static var sharedModelContainer: ModelContainer = {
        let schema = Schema([DoseEntry.self, Settings.self])
        // Update the group identifier to match your App Group identifier in Xcode.
        let url = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: "group.com.yourcompany.SevenOH")!
            .appendingPathComponent("SevenOH.store")
        let config = ModelConfiguration(url: url)
        do {
            return try ModelContainer(for: schema, configurations: config)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }()
}