
import SwiftUI
import Combine

private enum ByteMood: Equatable {
    case idle
    case happy
    case shy
    case playful
}

// create pivate enum byte actions
// private enum ByteAction: Equatable {
//     case blinking
//     // like jumping
//     // sneaky or truoble making option
// }

struct ContentView: View {
    @State private var positionX: CGFloat = 0
    @State private var  isMoving = false
    @State private var positionY: CGFloat = 0
    @State private var mode: ByteMood = .idle
    // @State private var action: ByteAction = .blinking
    @State private var isBreathing = false
    @State private var isBlinking = false

    private let maxX: CGFloat = 100
    private let maxY: CGFloat = 70

    private let timer = Timer.publish(
        every: 2,
        on: .main,
        in: .common
    ).autoconnect() // move timer

    private let blinkTimer = Timer.publish(
        every: 1,
        on: .main,
        in: .common
    ).autoconnect() // blink timer

    var body: some View {
        ZStack {
            byte
                .scaleEffect(
                    mode == .happy || mode == .playful ? 0.85 : 1.0
                )
                .offset(x: positionX, y: positionY)
                .onTapGesture {
                    petByte()
                }
        }
        .frame(width: 320, height: 260)
        .background(Color.clear)
        .onReceive(timer) { _ in
            wander()
            breathe()
        }
        .onReceive(blinkTimer) {_ in
            blinkWhileVisible()
        }
    }

    // MARK: - BYTE Appearance

    private var byte: some View {
        ZStack {
            Circle()
                .fill(RadialGradient(
                    colors: [
                        Color(red: 0.79, green: 0.99, blue: 1),
                        Color(red: 0.30, green: 0.80, blue: 0.90),
                        Color(red: 0.19, green: 0.61, blue: 0.76)
                    ],
                    center: .topLeading,
                    startRadius: 3,
                    endRadius: 120
                )) .frame(width: 100, height: 100)
                .frame(width: 100, height: 100)
                HStack(spacing: 46) {
                    cheek
                    cheek
                } .offset(y: 11)
                VStack(spacing: 3) {
                    byteEyes
                    byteMouth
                } .offset(y: 3)
        }
        .contentShape(Circle())
    }

    private var byteMouth: some View {
        Group {
            if mode == .shy {
                Ellipse().fill(.black).frame(width: 5, height: 7)
            } else {
                FaceArc(bend: mode == .idle ? 0.65 : 1)
                .stroke(.black, style: StrokeStyle(
                lineWidth: 2.2, lineCap: .round
                ))
                .frame(width: 15, height: 8)
            }
        }
        .frame(width: 20, height: 12)
    }

    private var cheek: some View {
        Ellipse()
            .fill(Color.pink.opacity(0.5))
            .frame(width: 15, height: 8)
            .blur(radius: 2)
    }

    private func eye(
            width: CGFloat = 10,
            height: CGFloat = 12
        ) -> some View {
            Capsule()
            .fill(Color.black)
            .frame(width: width, height: height)
            .overlay(alignment: .topLeading) {
                if height >= 8 {
                    Circle()
                    .fill(.white)
                    .frame(width: 3, height: 3)
                    .padding(2)
                }
            }
            .frame(width: 16, height: 16)
        }
     
    @ViewBuilder
    private var byteEyes: some View {
        HStack(spacing: 20) {
            if isBlinking {
                closedEye()
                closedEye()
            } else {
                switch mode {
                    case .idle:
                        eye()
                        eye()
                    case .happy:
                        closedEye()
                        closedEye()
                    case .shy:
                        eye(width: 8, height: 10)
                        eye(width: 8, height: 10)
                    case .playful:
                        closedEye()
                        eye()
                }
            }
        }
    }

    // private var byteAction: some View {
    //     HStack(spacing: 20){
    //         switch action {
    //             case .blinking:
    //                 closedEye()
    //                 closedEye()
    //         }
    //     }
    // }

    private func closedEye() -> some View {
        FaceArc(bend: -1)
            .stroke(.black, style: StrokeStyle(
                lineWidth: 2.5, lineCap: .round
            ))
                .frame(width: 12, height: 5)
                .frame(width: 16, height: 16)
    }

    private struct FaceArc: Shape {
        let bend: CGFloat
        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.move(to: CGPoint(x: rect.minX, y: rect.midY))
            path.addQuadCurve(
                to: CGPoint(x: rect.maxX, y: rect.midY),
                control: CGPoint(
                    x: rect.midX, y: rect.midY + rect.height * 0.8 * bend
                )
            )
            return path
            }
        }

    // MARK: - Movement

    private func wander() {
        guard mode == .idle, !isMoving, !isBlinking, !isBreathing else { return }
        moveByter()
    }

    private func blinkWhileVisible() {
        guard mode == .idle,!isBlinking else { return }
        guard Int.random(in: 1...3) == 3 else { return } // random chance not to blink

        isBlinking = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            isBlinking = false
        }
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

    

    // MARK: - Petting Reactions

    private func petByte() {
        guard mode == .idle, !isMoving, !isBlinking, !isBreathing else { return }

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

    private func move(
        toX x: CGFloat,
        y: CGFloat,
        duration: Double
    ) {
        guard !isMoving else { return }
        isMoving = true

        withAnimation(.easeInOut(duration: duration)) {
            positionX = min(maxX, max(-maxX, x))
            positionY = min(maxY, max(-maxY, y))
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            isMoving = false
        }
    }

    // make byte breathe 
    func breathe() {
        guard !isBreathing, !isMoving, !isBlinking else { return }
        isBreathing = true
        withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
            // scale the byte up and down
            byte.scaleEffect(1.05)
        }
        isBreathing = false
    }

    // private func performByte() {
    //     let action = ByteAction
    //     switch action {
    //         case .blinking: return  
    //     }
    // }
}
