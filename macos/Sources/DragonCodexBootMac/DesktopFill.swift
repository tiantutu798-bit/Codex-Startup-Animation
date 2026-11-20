import AppKit
import ApplicationServices

enum DesktopFill {
    private static let fullscreenAttribute = "AXFullScreen"

    @MainActor
    static func screen(containing targetFrame: CGRect?) -> NSScreen? {
        let screens = NSScreen.screens
        if let targetFrame {
            let overlaps = screens.compactMap { screen -> (NSScreen, CGFloat)? in
                let overlap = screen.frame.intersection(targetFrame)
                guard !overlap.isEmpty else { return nil }
                return (screen, overlap.width * overlap.height)
            }
            if let display = overlaps.max(by: { $0.1 < $1.1 }) {
                return display.0
            }
        }
        return NSScreen.main ?? screens.first
    }

    // Accessibility and Window Server use a top-left origin. AppKit uses a bottom-left origin.
    static func flipScreenCoordinates(_ frame: CGRect) -> CGRect {
        CGRect(
            x: frame.minX,
            y: CGDisplayBounds(CGMainDisplayID()).height - frame.maxY,
            width: frame.width,
            height: frame.height
        )
    }

    static func apply(to pid: pid_t, frame: CGRect) -> Bool {
        let app = AXUIElementCreateApplication(pid)
        AXUIElementSetMessagingTimeout(app, 0.15)
        let mainWindow: AXUIElement? = attribute(kAXMainWindowAttribute, of: app)
        let windows: [AXUIElement] = attribute(kAXWindowsAttribute, of: app) ?? []
        guard let window = ([mainWindow].compactMap { $0 } + windows).first(where: isStandardWindow) else {
            return false
        }

        AXUIElementSetMessagingTimeout(window, 0.15)
        let fullscreen: Bool? = attribute(fullscreenAttribute, of: window)
        if fullscreen == true {
            AXUIElementSetAttributeValue(window, fullscreenAttribute as CFString, kCFBooleanFalse)
            return false
        }

        let target = flipScreenCoordinates(frame)
        if matches(window, target) { return true }
        var position = target.origin
        var size = target.size
        guard let positionValue = AXValueCreate(.cgPoint, &position),
              let sizeValue = AXValueCreate(.cgSize, &size) else { return false }
        AXUIElementSetAttributeValue(window, kAXPositionAttribute as CFString, positionValue)
        AXUIElementSetAttributeValue(window, kAXSizeAttribute as CFString, sizeValue)
        AXUIElementSetAttributeValue(window, kAXPositionAttribute as CFString, positionValue)
        return matches(window, target)
    }

    private static func isStandardWindow(_ window: AXUIElement) -> Bool {
        AXUIElementSetMessagingTimeout(window, 0.15)
        let subrole: String? = attribute(kAXSubroleAttribute, of: window)
        let minimized: Bool? = attribute(kAXMinimizedAttribute, of: window)
        return subrole == kAXStandardWindowSubrole && minimized != true
    }

    private static func matches(_ window: AXUIElement, _ frame: CGRect) -> Bool {
        guard let positionValue: AXValue = attribute(kAXPositionAttribute, of: window),
              let sizeValue: AXValue = attribute(kAXSizeAttribute, of: window) else { return false }
        var position = CGPoint.zero
        var size = CGSize.zero
        guard AXValueGetValue(positionValue, .cgPoint, &position),
              AXValueGetValue(sizeValue, .cgSize, &size) else { return false }
        return abs(position.x - frame.minX) <= 1 &&
            abs(position.y - frame.minY) <= 1 &&
            abs(size.width - frame.width) <= 1 &&
            abs(size.height - frame.height) <= 1
    }

    private static func attribute<T>(_ key: String, of element: AXUIElement) -> T? {
        var value: CFTypeRef?
        guard AXUIElementCopyAttributeValue(element, key as CFString, &value) == .success else {
            return nil
        }
        return value as? T
    }
}
