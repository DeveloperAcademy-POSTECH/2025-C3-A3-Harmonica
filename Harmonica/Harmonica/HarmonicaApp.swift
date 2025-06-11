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
    
    @State private var isSplashFinished: Bool = false
    
    var body: some Scene {
        WindowGroup {
//            if isSplashFinished {
//                MainView()
//            }
////            KaraokeLyricView()
//            else{
//                SplashView{
//                    isSplashFinished = true
//                }
//            }
//
            MainView()
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
