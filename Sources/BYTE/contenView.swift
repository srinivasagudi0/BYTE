import SwiftUI
import Combine

enum ByteMood {
    case happy
    case shy
    case playful
    case idle
}

struct ContentView: View {
    @State private var positionX = 0.0
    @State private var positionY = 0.0
    @State private var mode: ByteMood = .idle
    // reactions
    @State private var isReacting = false

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
                .onTapGesture {
                    petByte()
                }
                .scaleEffect(isReacting ? 1.2 : 1.0)

            }
        }
        .frame(width: 600, height: 400)
        .onReceive(timer) { _ in
            wander()
        }
    }

    func wander() {
        guard !isReacting else { return }

        moveByter()
    }

    func petByte() {
        guard !isReacting else { return }

        let reaction = Int.random(in: 0...100)

        if reaction <= 45 {
            // is happy
            // isReacting = true
            // isHappy = true
            // isShy = false
            // isPlayful = false
        } else if reaction <= 75 {
            // shy
            isReacting = true
            isHappy = false
            isShy = true
            isPlayful = false
        } else {
            // playful
            // isReacting = true
            // isHappy = true
            // isPlayful = true
            // isShy = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.easeInOut(duration: 0.5)) {
                // isReacting = false
                // isHappy = false
                // isShy = false
                // isPlayful = false
            }
        }
    }

    func moveByter(duration: Double = 1.0) {
        withAnimation(.easeInOut(duration: duration)) {
            positionX = Double.random(in: -240...240)
            positionY = Double.random(in: -140...140)
        }
    }
}

