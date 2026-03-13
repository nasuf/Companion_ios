import SwiftUI

@main
struct CompanionApp: App {
    @State private var appViewModel = AppViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appViewModel)
                .preferredColorScheme(appViewModel.colorScheme)
                .environment(\.locale, Locale(identifier: appViewModel.locale.rawValue))
        }
    }
}
