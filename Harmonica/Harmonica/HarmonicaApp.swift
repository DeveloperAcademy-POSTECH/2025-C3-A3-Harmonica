// HarmonicaApp.swift
import SwiftUI

@main
struct HarmonicaApp: App {
    var body: some Scene {
        WindowGroup {
            SongPracticeView(song: .preview)
        }
        .modelContainer(for: Song.self)
    }
}
