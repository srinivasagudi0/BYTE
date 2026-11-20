
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

        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = false
        window.level = .floating

        window.styleMask.insert(.fullSizeContentView)
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true

        window.standardWindowButton(.closeButton)?.isHidden = true
        window.standardWindowButton(.miniaturizeButton)?.isHidden = true
        window.standardWindowButton(.zoomButton)?.isHidden = true
        window.styleMask = [.borderless]
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = false
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true

        window.contentView?.wantsLayer = true
        window.contentView?.layer?.backgroundColor = NSColor.clear.cgColor
    }
}
