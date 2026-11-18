
import SwiftUI
import Combine

struct ContentView: View {
    @State private var positionX = 0.0
    @State private var positionY = 0.0

    let timer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.black) // Background

            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(Color.cyan)
                        .frame(width: 100, height: 100) // BYTE's body

                    HStack(spacing: 20) {
                        Circle()
                            .fill(Color.black)
                            .frame(width: 12, height: 12) // Left eye

                        Circle()
                            .fill(Color.black)
                            .frame(width: 12, height: 12) // Right eye
                    }
                }
                .offset(x: positionX, y: positionY)

            }
        }
        .frame(width: 600, height: 400)
        .onReceive(timer) { _ in
            wander()
        }
    }

    func wander() {
        withAnimation(.easeInOut(duration: 1.0)) {
            positionX = Double.random(in: -100...100)
            positionY = Double.random(in: -100...100)
        }
    }
}
