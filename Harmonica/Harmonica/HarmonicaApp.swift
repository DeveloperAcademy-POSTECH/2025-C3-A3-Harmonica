import SwiftUI
import SwiftData

@main
struct HarmonicaApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
  
    let container: ModelContainer
    
    init() {
        do {
            container = try ModelContainer(for: SongInfo.self)
        } catch {
            fatalError("FAIL SwiftData container init: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
//            KaraokeLyricView()
            MainView()
//            SongSearchView()
//            SearchResultView()
            .modelContainer(container)
            .onAppear {
                Task { @MainActor in
                    let dataManager = SongDataManager(modelContext: container.mainContext)
                    dataManager.loadDefaultSongsIfNeeded()
                }
            }
        }
        .modelContainer(for: SongInfo.self)
    }
}
