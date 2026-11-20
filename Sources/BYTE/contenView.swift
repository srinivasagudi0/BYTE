import AppKit
import SwiftUI
import Combine

private enum ByteMood: Equatable {
    case idle
    case happy
    case shy
    case playful
    case sleeping
}

// create pivate enum byte actions
// private enum ByteAction: Equatable {
//     case blinking
//     // like jumping
//     // sneaky or truoble making option
// }

struct ContentView: View {
    // @State private var positionX: CGFloat = 0
    @State private var  isMoving = false
    // @State private var positionY: CGFloat = 0
    @State private var mode: ByteMood = .idle
    @State private var isJumping = false
    @State private var jumpHeight: CGFloat = 0
    // @State private var action: ByteAction = .blinking
    @State private var isBreathing = false
    @State private var isBlinking = false
    @State private var isResting = false
    @State private var lastInteractionTime = Date()
    @State private var isSleeping = false
    @State private var isRoamingPaused = false
    @State private var jumpScaleX: CGFloat = 1
    @State private var jumpScaleY: CGFloat = 1 

    @AppStorage("byte.palette") private var palette = "Ocean"

    private var bodyColors: [Color] {
        switch palette {
            case "Berry":
                return [Color.pink.opacity(0.35), .pink, .purple]
            case "Mint":
                return [Color.green.opacity(0.35), .mint, .teal]
            case "Dusk":
                return [
                    Color(red: 0.82, green: 0.72, blue: 1.0),
                    Color(red: 0.55, green: 0.40, blue: 0.90),
                    Color(red: 0.35, green: 0.20, blue: 0.65)
                ]
            default:
                return [
                    Color(red: 0.79, green: 0.99, blue: 1),
                    Color(red: 0.30, green: 0.80, blue: 0.90),
                    Color(red: 0.19, green: 0.61, blue: 0.76)
                ]
        }
    }

    private var maxX: CGFloat {
        max(0, (NSScreen.main?.visibleFrame.width ?? 1000) / 2 - 60)
    }

    private var maxY: CGFloat {
        max(0, (NSScreen.main?.visibleFrame.height ?? 700) / 2 - 60)
    }

    @State private var positionX: CGFloat = 0
    @State private var positionY: CGFloat = 0

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
                .frame(width: 100, height: 100)
                .scaleEffect(
                    (mode == .happy || mode == .playful ? 0.85 : 1.0) 
                    * (isBreathing ? 1.05: 1.0)
                )
                .scaleEffect(
                    x: jumpScaleX,
                    y: jumpScaleY
                )
                .offset(x: positionX, y: positionY + jumpHeight)
                .gesture(
                    TapGesture(count: 2) 
                        .exclusively(before: TapGesture(count: 1))
                        .onEnded { result in 
                            switch result {
                                case .first(_):
                                    jump()
                                case .second(_):
                                    petByte()
                            }

                        }
                )
                .contextMenu {
                    if mode == .sleeping {
                        Button("Wake Up") { petByte() }
                    } else {
                        Button("Sleep Now") { fallAsleep() }
                            .disabled(mode != .idle || isMoving || isJumping )
                    }

                    Divider()
                    
                    Button(isRoamingPaused ? "Resume Roaming" : "Pause Roaming") {
                        isRoamingPaused.toggle()
                    }
                    Picker("Color", selection: $palette) {
                        Text("Ocean").tag("Ocean")
                        Text("Berry").tag("Berry")
                        Text("Mint").tag("Mint")
                        Text("Dusk").tag("Dusk")
                    }
                    Divider()

                    Button("QUIT BYTE") {
                        NSApplication.shared.terminate(nil)
                    }
                }
                .onAppear {
                    breathe()
                }
        }
        // The window is full-screen; the pet moves relative to its center.
        // Keep the root transparent so only BYTE participates in hit-testing.
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.clear)
        .onReceive(timer) { _ in
            checkSleep()
            guard !isRoamingPaused else { return }

            if Int.random(in: 1...3) == 3 {
                jump()
            } else {
                wander()
            }
        }
        .onReceive(blinkTimer) {_ in
            blinkWhileVisible()
        }
    }

    // MARK: - BYTE Appearance
    private func wander() {
        guard mode == .idle, !isMoving, !isJumping, !isResting, !isSleeping else { return }
        moveByter()
    }

    private var byte: some View {
        ZStack {
            Circle()
                .fill(RadialGradient(
                    colors: bodyColors,
                    center: .topLeading,
                    startRadius: 3,
                    endRadius: 120
                ))
                 .frame(width: 100, height: 100)
                .frame(width: 100, height: 100)
                HStack(spacing: 46) {
                    cheek
                    cheek
                } .offset(y: 11)
                VStack(spacing: 3) {
                    byteEyes
                    byteMouth
                } .offset(y: 3)
                jumpLines
                    .opacity(isJumping ? 1 : 0)
                    .scaleEffect(isJumping ? 1 : 0.7)
                    .animation(.easeInOut(duration: 0.18), value: isJumping)
                    .allowsHitTesting(false)
        }
        .contentShape(Circle())
        .overlay(alignment: .topTrailing) {
            if mode == .sleeping {
                SleepZzz()
                    .padding(.top, 12)
                    .padding(.trailing, 20)
                    .allowsHitTesting(false)
            }
        }
        .overlay(alignment: .topTrailing) {
                    if mode == .happy {
                        HeartPop()
                            .padding(.top, 25)
                            .allowsHitTesting(false)
                    }
                }
    }

    private var byteMouth: some View {
        Group {
            if mode == .shy  || mode == .sleeping {
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
                    case .sleeping:
                        closedEye()
                        closedEye()
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
            toX: positionX + CGFloat.random(in: -200...200),
            y: positionY + CGFloat.random(in: -150...150),
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
        if isSleeping {
            isSleeping = false
            lastInteractionTime = Date()

            withAnimation(.spring(duration: 0.35)) {
                mode = .idle
            }
            return
        }
        guard mode == .idle, !isMoving, !isBlinking, !isJumping else { return }
        lastInteractionTime = Date()

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
        
        case .sleeping:
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
            isResting = true

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isResting = false
            }
        }
    }

    // make byte breathe 
    func breathe() {
        guard !isBreathing else { return }
        withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
            // scale the byte up and down
            isBreathing = true
        }
    }

    private var jumpLines: some View {
        HStack(spacing: 110) {
            motionLines
                .rotationEffect(.degrees(-20))
            motionLines
                .rotationEffect(.degrees(20))
        }
    }

    private var motionLines: some View {
        VStack(spacing: 6) {
            ForEach(0..<3, id: \.self) { _ in
                Capsule()
                    .fill(bodyColors.last ?? .black)
                    .frame(width: 15, height: 3)
            }
        }
    }

    func jump() {
        guard !isJumping, !isMoving, mode == .idle, !isResting, !isSleeping else { return }
        isJumping = true

        withAnimation(.easeOut(duration: 0.3)) {
            jumpHeight = -110
            jumpScaleX = 0.92
            jumpScaleY = 1.12
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {

            // Falling
            withAnimation(.easeIn(duration: 0.3)) {
                jumpHeight = 0
                jumpScaleX = 1
                jumpScaleY = 1
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {

                // Landing: wider and shorter
                withAnimation(.easeOut(duration: 0.1)) {
                    jumpScaleX = 1.15
                    jumpScaleY = 0.85
                }

                // Recover
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.spring(duration: 0.25)) {
                        jumpScaleX = 1
                        jumpScaleY = 1
                    }
                }

                isJumping = false
                isResting = true

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isResting = false
                }
            }
        }
    }

    private func checkSleep() {
        guard Date().timeIntervalSince(lastInteractionTime) >= 30 else { return }

        fallAsleep()
    }

    private func fallAsleep() {
        guard mode == .idle, !isSleeping, !isMoving, !isJumping else { return }

        withAnimation(.easeInOut(duration: 0.4)) {
            isSleeping = true
            mode = .sleeping
        }
    }

    private struct SleepZzz: View {
        @State private var isFloating = false
        var body: some View{
            Text("Zzz")
            .font(.system(size: 15, weight:  .bold, design: .rounded))
            .foregroundColor(Color.indigo)
            .offset(y: isFloating ? -12 : 0)
            .opacity(isFloating ? 0.15 : 0.9)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: false)) {
                    isFloating = true
                }
            }
        }  
    }

    private struct HeartPop: View {
        @State private var floating = false

        var body: some View {
            Image(systemName: "heart.fill")
                .font(.system(size: 16))
                .foregroundColor(.pink)
                .offset(y: floating ? -25 : 0)
                .opacity(floating ? 0 : 1)
                .onAppear {
                    withAnimation(.easeInOut(duration: 0.8)) {
                        floating = true
                    }
                }
        }
    }

    // private func performByte() {
    //     let action = ByteAction
    //     switch action {
    //         case .blinking: return  
    //     }
    // }
}

