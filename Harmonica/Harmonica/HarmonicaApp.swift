// HarmonicaApp.swift
import SwiftUI

@main
struct HarmonicaApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
            .onAppear {
              Task {
                await PermissionManager.requestSTTPermissions()
              }
            }
        }
    }
}
