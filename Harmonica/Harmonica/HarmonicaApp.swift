// HarmonicaApp.swift
import SwiftUI

@main
struct HarmonicaApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
  
    var body: some Scene {
        WindowGroup {
//            KaraokeLyricView()
            MainView()
//            SongSearchView()
//            SearchResultView()
        }
    }
}
