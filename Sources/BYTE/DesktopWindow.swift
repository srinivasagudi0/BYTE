import SwiftUI
import AppKit


struct ByteApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .background(DesktopWindow())
        }
         .defaultSize(width: 320, height: 260)
    }
}

private var byteMouth: some View {
    Smile()
        .stroke(
            Color.black,
            style: StrokeStyle(
                lineWidth: 2.5,
                lineCap: .round
            )
        )
        .frame(width: 18, height: 10)
}