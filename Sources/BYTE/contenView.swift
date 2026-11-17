import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.black)
        }.frame(width: 600, height: 400)
    }
}