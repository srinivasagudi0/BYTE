import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.black)
            Circle()
                HStack {
                    Circle()
                        .fill(Color.black)
                        .frame(width: 50, height: 50)
                    Circle()
                        .fill(Color.black)
                        .frame(width: 50, height: 50)
                }
                .fill(Color.cyan)
                .frame(width: 100, height: 100)
        }.frame(width: 600, height: 400)
    }
}
