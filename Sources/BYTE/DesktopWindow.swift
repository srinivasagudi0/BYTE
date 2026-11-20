
import SwiftUI
import AppKit

struct DesktopWindow: NSViewRepresentable {

    func makeNSView(context: Context) -> NSView {
        WindowConfigurator()
    }

    func updateNSView(_ view: NSView, context: Context) {}
}

private final class WindowConfigurator: NSView {
    private var didConfigureWindow = false

    override func viewDidMoveToWindow() {
    super.viewDidMoveToWindow()

        guard !didConfigureWindow else { return }

        // SwiftUI can attach this view before the hosting window has finished
        // being installed. Configure it on the next main-run-loop turn.
        DispatchQueue.main.async { [weak self] in
            guard let self, let window = self.window, !self.didConfigureWindow else { return }

            self.didConfigureWindow = true
            window.styleMask = [.borderless]
            window.setFrame(window.screen?.frame ?? NSScreen.main?.frame ?? window.frame, display: true)

            window.isOpaque = false
            window.backgroundColor = .clear
            window.hasShadow = false
            window.level = .floating

            window.collectionBehavior = [
                .canJoinAllSpaces,
                .fullScreenAuxiliary
            ]

            window.ignoresMouseEvents = false
        }
    }
}
