import SwiftUI

@main
struct OracleApp: App {
    // Single shared store for the entire app.
    @StateObject private var store = TaskStore()
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(store)
        }
    }
}

