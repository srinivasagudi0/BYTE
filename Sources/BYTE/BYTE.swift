// The Swift Programming Language
// https://docs.swift.org/swift-book
import SwiftUI

@main
struct BYTEApp: App {
    var body: some Scene {
        WindowsGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    var body: some View {
        ZStack {
            Color.black

            Text("Hello, BYTE!")
                .font(.largeTitle)
                .foregroundColor(.white)
        }.frame(width: 600, height: 400)
    }   
}