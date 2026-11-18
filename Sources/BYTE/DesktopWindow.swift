import SwiftUI
import AppKit

@main
struct ByteApp: App {
    var body: some Scene {
        windowGroup {
            ContentView()
                .background(DesktopWindow())
        }
         .defaultSize(width: 320, height: 260)
    }
}

