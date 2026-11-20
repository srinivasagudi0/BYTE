
import SwiftUI
import AppKit

struct DesktopWindow: NSViewRepresentable {

    func makeNSView(context: Context) -> NSView {
        WindowConfigurator()
    }

    func updateNSView(_ view: NSView, context: Context) {}
}

private final class WindowConfigurator: NSView {

   override func viewDidMoveToWindow() {
    super.viewDidMoveToWindow()

    guard let window = self.window else { return }

    window.styleMask = [.borderless]
    window.setFrame(NSScreen.main?.frame ?? window.frame, display: true)

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
