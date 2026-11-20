
import SwiftUI
import AppKit

struct DesktopWindow: NSViewRepresentable {
    @MainActor final class HitRegion {
        var offset: CGSize = .zero
        var bodyScale: CGFloat = 1
        var jumpScale = CGSize(width: 1, height: 1)

        func contains(_ point: CGPoint, bodySize: CGFloat) -> Bool {
            let radius = bodySize / 2 * bodyScale
            let x = (point.x - offset.width) / (radius * jumpScale.width)
            let y = (point.y - offset.height) / (radius * jumpScale.height)
            return x * x + y * y <= 1
        }
    }

    let hitRegion: HitRegion
    let bodySize: CGFloat

    func makeNSView(context: Context) -> NSView {
        WindowConfigurator(hitRegion: hitRegion, bodySize: bodySize)
    }

    func updateNSView(_ view: NSView, context: Context) {}
}

private final class WindowConfigurator: NSView {
    private let hitRegion: DesktopWindow.HitRegion
    private let bodySize: CGFloat
    private var mouseTimer: Timer?

    init(hitRegion: DesktopWindow.HitRegion, bodySize: CGFloat) {
        self.hitRegion = hitRegion
        self.bodySize = bodySize
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) { nil }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()

        mouseTimer?.invalidate()
        mouseTimer = nil
        guard let window else { return }
        window.ignoresMouseEvents = true

        // SwiftUI can attach this view before the hosting window has finished
        // being installed. Configure it on the next main-run-loop turn.
        DispatchQueue.main.async { [weak self, weak window] in
            guard let self, let window, self.window === window, self.mouseTimer == nil else { return }

            window.styleMask = [.borderless]
            let screen = window.screen ?? NSScreen.main
            if let screen {
                window.setFrame(screen.frame, display: true)
            }

            window.isOpaque = false
            window.backgroundColor = .clear
            window.hasShadow = false
            window.level = .floating

            window.collectionBehavior = [
                .canJoinAllSpaces,
                .fullScreenAuxiliary
            ]

            // The overlay cannot receive mouse-moved events while click-through.
            // Check the pointer even when it is still and BYTE moves underneath it.
            let timer = Timer(timeInterval: 1.0 / 60.0, repeats: true) { [weak self] timer in
                guard let self else {
                    timer.invalidate()
                    return
                }
                MainActor.assumeIsolated { self.updateMouseRouting() }
            }
            self.mouseTimer = timer
            RunLoop.main.add(timer, forMode: .common)
            self.updateMouseRouting()
        }
    }

    private func updateMouseRouting() {
        // Leave the mouse-down and mouse-up with the same window during a click or drag.
        guard let window, NSEvent.pressedMouseButtons == 0 else { return }
        let local = convert(window.mouseLocationOutsideOfEventStream, from: nil)
        let point = CGPoint(x: local.x - bounds.midX,
                            y: isFlipped ? local.y - bounds.midY : bounds.midY - local.y)
        let ignoreMouse = !hitRegion.contains(point, bodySize: bodySize)
        if window.ignoresMouseEvents != ignoreMouse {
            window.ignoresMouseEvents = ignoreMouse
        }
    }
}

// Report the interpolated pose used for drawing, so input follows BYTE during animations.
struct ByteTransform: GeometryEffect {
    var offset: CGSize = .zero
    var scale: CGSize
    let report: @MainActor @Sendable (CGSize, CGSize) -> Void

    var animatableData: AnimatablePair<CGSize.AnimatableData, CGSize.AnimatableData> {
        get { AnimatablePair(offset.animatableData, scale.animatableData) }
        set {
            offset.animatableData = newValue.first
            scale.animatableData = newValue.second
        }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        let (offset, scale, report) = (offset, scale, report)
        DispatchQueue.main.async { report(offset, scale) }
        let transform = CGAffineTransform(
            a: scale.width, b: 0, c: 0, d: scale.height,
            tx: offset.width + size.width * (1 - scale.width) / 2,
            ty: offset.height + size.height * (1 - scale.height) / 2
        )
        return ProjectionTransform(transform)
    }
}
