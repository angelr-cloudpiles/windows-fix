import AppKit
import ApplicationServices

/// A connected display identified by its hardware UUID (stable across reconnects).
struct DisplayInfo {
    let uuid: String
    /// Bounds in global top-left-origin coordinates (same space as the Accessibility API).
    let bounds: CGRect

    static func connected() -> [DisplayInfo] {
        var count: UInt32 = 0
        CGGetActiveDisplayList(0, nil, &count)
        var ids = [CGDirectDisplayID](repeating: 0, count: Int(count))
        CGGetActiveDisplayList(count, &ids, &count)
        return ids.prefix(Int(count)).compactMap { id in
            guard let cfUUID = CGDisplayCreateUUIDFromDisplayID(id)?.takeRetainedValue(),
                  let string = CFUUIDCreateString(nil, cfUUID) as String? else { return nil }
            return DisplayInfo(uuid: string, bounds: CGDisplayBounds(id))
        }
    }
}

/// Reads and moves windows of other apps through the Accessibility API.
enum WindowService {
    struct LiveWindow {
        let element: AXUIElement
        let title: String
        let frame: CGRect
    }

    // MARK: Permission

    static var isTrusted: Bool { AXIsProcessTrusted() }

    static func requestTrust() {
        // Literal value of kAXTrustedCheckOptionPrompt (the global is not concurrency-safe).
        _ = AXIsProcessTrustedWithOptions(["AXTrustedCheckOptionPrompt": true] as CFDictionary)
    }

    // MARK: Capture

    static func captureWindows() -> [SavedWindow] {
        let displays = DisplayInfo.connected()
        var result: [SavedWindow] = []

        for app in regularApps() {
            guard let bundleID = app.bundleIdentifier else { continue }
            for (index, window) in liveWindows(of: app).enumerated() {
                guard let display = bestDisplay(for: window.frame, in: displays) else { continue }
                result.append(SavedWindow(
                    bundleID: bundleID,
                    appName: app.localizedName ?? bundleID,
                    title: window.title,
                    index: index,
                    displayUUID: display.uuid,
                    relativeOrigin: CGPoint(x: window.frame.minX - display.bounds.minX,
                                            y: window.frame.minY - display.bounds.minY),
                    size: window.frame.size
                ))
            }
        }
        return result
    }

    // MARK: Restore

    /// Moves/resizes live windows to match the layout. Returns (restored, skipped) counts.
    static func restore(_ layout: SavedLayout) -> (restored: Int, skipped: Int) {
        let displays = DisplayInfo.connected()
        let running = Dictionary(grouping: regularApps(), by: { $0.bundleIdentifier ?? "" })
        var restored = 0
        var skipped = 0

        for (bundleID, saved) in Dictionary(grouping: layout.windows, by: \.bundleID) {
            guard let app = running[bundleID]?.first else { skipped += saved.count; continue }
            var available = liveWindows(of: app)

            for target in saved.sorted(by: { $0.index < $1.index }) {
                // Prefer an exact title match, otherwise fall back to the next window in order.
                let matchIndex = available.firstIndex { !target.title.isEmpty && $0.title == target.title }
                    ?? (available.isEmpty ? nil : 0)
                guard let matchIndex else { skipped += 1; continue }
                let window = available.remove(at: matchIndex)

                // Saved display missing (monitor unplugged): leave the window where it is.
                guard let display = displays.first(where: { $0.uuid == target.displayUUID }) else {
                    skipped += 1
                    continue
                }
                let origin = CGPoint(x: display.bounds.minX + target.relativeOrigin.x,
                                     y: display.bounds.minY + target.relativeOrigin.y)
                apply(origin: origin, size: target.size, to: window.element)
                restored += 1
            }
        }
        return (restored, skipped)
    }

    // MARK: Helpers

    private static func regularApps() -> [NSRunningApplication] {
        let myPID = ProcessInfo.processInfo.processIdentifier
        return NSWorkspace.shared.runningApplications.filter {
            $0.activationPolicy == .regular && $0.processIdentifier != myPID
        }
    }

    private static func bestDisplay(for frame: CGRect, in displays: [DisplayInfo]) -> DisplayInfo? {
        displays.max { lhs, rhs in
            area(of: lhs.bounds.intersection(frame)) < area(of: rhs.bounds.intersection(frame))
        }
    }

    private static func area(of rect: CGRect) -> CGFloat {
        rect.isNull ? 0 : rect.width * rect.height
    }

    /// Standard, non-minimized windows of an app.
    private static func liveWindows(of app: NSRunningApplication) -> [LiveWindow] {
        let appElement = AXUIElementCreateApplication(app.processIdentifier)
        guard let elements = attribute(kAXWindowsAttribute, of: appElement) as? [AXUIElement] else { return [] }

        return elements.compactMap { element in
            guard attribute(kAXSubroleAttribute, of: element) as? String == kAXStandardWindowSubrole,
                  attribute(kAXMinimizedAttribute, of: element) as? Bool != true,
                  let position = axValue(kAXPositionAttribute, of: element, type: .cgPoint, as: CGPoint.self),
                  let size = axValue(kAXSizeAttribute, of: element, type: .cgSize, as: CGSize.self)
            else { return nil }
            let title = attribute(kAXTitleAttribute, of: element) as? String ?? ""
            return LiveWindow(element: element, title: title, frame: CGRect(origin: position, size: size))
        }
    }

    /// Size first, then position, then size again: some apps clamp size to the current display.
    private static func apply(origin: CGPoint, size: CGSize, to element: AXUIElement) {
        setValue(size, type: .cgSize, attribute: kAXSizeAttribute, on: element)
        setValue(origin, type: .cgPoint, attribute: kAXPositionAttribute, on: element)
        setValue(size, type: .cgSize, attribute: kAXSizeAttribute, on: element)
    }

    private static func attribute(_ name: String, of element: AXUIElement) -> CFTypeRef? {
        var value: CFTypeRef?
        guard AXUIElementCopyAttributeValue(element, name as CFString, &value) == .success else { return nil }
        return value
    }

    private static func axValue<T>(_ name: String, of element: AXUIElement,
                                   type: AXValueType, as _: T.Type) -> T? {
        guard let raw = attribute(name, of: element), CFGetTypeID(raw) == AXValueGetTypeID() else { return nil }
        let value = unsafeBitCast(raw, to: AXValue.self)
        // Zero-initialised storage is safe here: T is CGPoint or CGSize.
        let pointer = UnsafeMutablePointer<T>.allocate(capacity: 1)
        defer { pointer.deallocate() }
        guard AXValueGetValue(value, type, pointer) else { return nil }
        return pointer.pointee
    }

    private static func setValue<T>(_ value: T, type: AXValueType, attribute name: String, on element: AXUIElement) {
        // Explicit byte access avoids the implicit T -> UnsafeRawPointer conversion; T is CGPoint or CGSize.
        let created = withUnsafeBytes(of: value) { buffer in
            buffer.baseAddress.flatMap { AXValueCreate(type, $0) }
        }
        guard let axValue = created else { return }
        AXUIElementSetAttributeValue(element, name as CFString, axValue)
    }
}
