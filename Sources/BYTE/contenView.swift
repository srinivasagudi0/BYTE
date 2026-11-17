import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.black)
            Circle()
                .fill(Color.cyan)
                .frame(width: 100, height: 100)
            HStack(spacing: 20) {
                Circle()
                    .fill(Color.black)
                    .frame(width: 12, height: 12)
                Circle()
                    .fill(Color.black)
                    .frame(width: 12, height: 12)
        }
        }.frame(width: 600, height: 400)
        
    }
}
