// HarmonicaApp.swift
import SwiftUI

@main
struct HarmonicaApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
  
    var body: some Scene {
        WindowGroup {
            MainView()
//            SongSearchView()
//            SearchResultView()
        }
    }
}
