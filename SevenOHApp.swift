import SwiftUI
import SwiftData

@main
struct SevenOHApp: App {
    @State private var route: AppRoute = .none

    var body: some Scene {
        WindowGroup {
            RootView(route: $route)
                .modelContainer(Persistence.sharedModelContainer)
                .onOpenURL { url in
                    if url.scheme == "sevenoh", url.host == "log" {
                        route = .presentLog
                    }
                }
        }
    }
}

enum AppRoute {
    case none
    case presentLog
}