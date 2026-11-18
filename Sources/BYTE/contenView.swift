import SwiftUI

struct ContentView: View {
    @State private var positionX = 0.0

    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.black) // Background

            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(Color.cyan)
                        .frame(width: 100, height: 100) // BYTE's Body

                    HStack(spacing: 20) {
                        Circle()
                            .fill(Color.black)
                            .frame(width: 12, height: 12) // Left eye

                        Circle()
                            .fill(Color.black)
                            .frame(width: 12, height: 12) // Right eye
                    }
                }
                .offset(x: positionX, y: 0)

                HStack(spacing: 20) {
                    Button("Move Left") {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            positionX -= 20
                        }
                    }

                    Button("Move Right") {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            positionX += 20
                        }
                    }
                }
            }
        }
        .frame(width: 600, height: 400)
    }
}