// The Swift Programming Language
// https://docs.swift.org/swift-book
import SwiftUI

@main
struct BYTEApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .background(DesktopWindow().allowsHitTesting(false))
        }
            .defaultSize(width: 320, height: 260)
    }
}

