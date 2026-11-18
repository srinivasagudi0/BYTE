
import SwiftUI
import Combine

private enum ByteMood: Equatable {
    case idle
    case happy
    case shy
    case playful
}

struct ContentView: View {
    @State private var positionX: CGFloat = 0
    @State private var positionY: CGFloat = 0
    @State private var mode: ByteMood = .idle

    private let maxX: CGFloat = 100
    private let maxY: CGFloat = 70

    private let timer = Timer.publish(
        every: 2,
        on: .main,
        in: .common
    ).autoconnect()

    var body: some View {
        ZStack {
            byte
                .offset(x: positionX, y: positionY)
                .scaleEffect(
                    mode == .happy || mode == .playful ? 0.85 : 1.0
                )
                .onTapGesture {
                    petByte()
                }
        }
        .frame(width: 320, height: 260)
        .background(Color.clear)
        .onReceive(timer) { _ in
            wander()
        }
    }

    // MARK: - BYTE Appearance

    private var byte: some View {
        ZStack {
            Circle()
                .fill(Color.cyan)
                .frame(width: 100, height: 100)

            byteEyes
        }
        .contentShape(Circle())
    }

    private func eye(
        width: CGFloat = 12,
        height: CGFloat = 12
    ) -> some View {
        Capsule()
            .fill(Color.black)
            .frame(width: width, height: height)
    }

    // MARK: - Movement

    private func wander() {
        guard mode == .idle else { return }

        moveByter()
    }

    private func moveByter(duration: Double = 1.0) {
        move(
            toX: positionX + CGFloat.random(in: -45...45),
            y: positionY + CGFloat.random(in: -35...35),
            duration: duration
        )
    }

    private func moveDiagonally() {
        move(
            toX: diagonalTarget(from: positionX, limit: maxX),
            y: diagonalTarget(from: positionY, limit: maxY),
            duration: 0.5
        )
    }

    private func diagonalTarget(
        from current: CGFloat,
        limit: CGFloat
    ) -> CGFloat {
        let step = CGFloat.random(in: 45...70)

        let direction: CGFloat = Bool.random() ? 1 : -1
        let target = current + step * direction

        if target > limit || target < -limit {
            return current - step * direction
        }

        return target
    }

    private func move(
        toX x: CGFloat,
        y: CGFloat,
        duration: Double
    ) {
        withAnimation(.easeInOut(duration: duration)) {
            positionX = min(maxX, max(-maxX, x))
            positionY = min(maxY, max(-maxY, y))
        }
    }

    // MARK: - Petting Reactions

    private func petByte() {
        guard mode == .idle else { return }

        let roll = Int.random(in: 1...100)
        let reaction: ByteMood

        switch roll {
        case 1...45:
            reaction = .happy

        case 46...75:
            reaction = .shy

        default:
            reaction = .playful
        }

        withAnimation(.spring(duration: 0.35)) {
            mode = reaction
        }

        switch reaction {
        case .happy:
            break

        case .shy:
            moveDiagonally()

        case .playful:
            DispatchQueue.main.asyncAfter(
                deadline: .now() + 0.4
            ) {
                moveDiagonally()
            }

        case .idle:
            break
        }

        DispatchQueue.main.asyncAfter(
            deadline: .now() + 1.2
        ) {
            withAnimation(.spring(duration: 0.35)) {
                mode = .idle
            }
        }
    }
}
