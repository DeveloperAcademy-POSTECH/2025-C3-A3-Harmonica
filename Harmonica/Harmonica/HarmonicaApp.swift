import SwiftUI
import SwiftData

@main
struct HarmonicaApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
  
    var body: some Scene {
        WindowGroup {
            MainView()
//            SongSearchView()
//            SearchResultView()
        }
        .modelContainer(for: Song.self)
    }
}
