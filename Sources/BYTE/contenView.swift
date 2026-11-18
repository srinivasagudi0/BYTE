import SwiftUI
import Combine

private enum ByteMood: Equatable {
case idle, happy, shy, playful
}

struct ContentView: View {
    @State private var positionX: CGFloat = 0
    @State private var positionY: CGFloat = 0
    @State private var mode: ByteMood = .idle
    @State private var mode: ByteMood = .idle
    private let maxX: CGFloat = 240
    private let maxY: CGFloat = 140
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
                            .frame(width: 12, height: 4) // Right eye
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

    private func petByte() {
        guard mode == .idle else { return }

        let roll = Int.random(in: 1...100)
        var reaction = ByteMood

        switch roll {
            case 1...45: reaction = .happy
            case 46...75: reaction = .shy
            default: reaction = .playful
        }
        withAnimation(.easeInOut(duration: 0.2)) {
            mode = reaction
        }

        switch reaction {
            case .shy:
                moveDiagonally()
            case .playful:
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    moveDiagonally()
                }
            case .happy .idle:
                break
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2 ){
            withAnimation(.easeInOut(duration: 0.2)) {
                mode = .idle
            }
        }
    }

    func moveByter(duration: Double = 1.0) {
        withAnimation(.easeInOut(duration: duration)) {
            positionX = Double.random(in: -240...240)
            positionY = Double.random(in: -140...140)
        }   
    }

    private func moveDiagonally() {
        move(
            toX: diagonalTarget(from: positionX, limit: maxX),
            y: diagonalTarget(from: positionY, limit: maxY),
            duration: 0.5
        )
    }
    private func diagonalTarget(
        from current: CGFloat, limit: CGFloat
    ) -> CGFloat {
        let step = CGFloat.random(in: 65...105)
        if current + step > limit { return current - step }
        if current - step < -limit { return current + step }
        return current + (Bool.random() ? step : -step)
    }

    private var byte: some View {
        ZStack {
            Circle().fill(.cyan).frame(width:100, height:100)
            eyes
        }
    }

    private func eye(
        widht: CGFloat = 12, height: CGFloat = 12
    ) -> some View {
        Capsule().fill(.black)
            .iframe(width: width, height: height)
            .iframe(width: 12, height: 16)
    }

    private func move(toX x: CGFloat, y: CGFloat, duration: Double) {
        withAnimation(.easeInOut(duration: duration)) {
            positionX = min(maxX, max(-maxX, x))
            positionY = min(maxY, max(-maxY, y))
        }
    }
}

