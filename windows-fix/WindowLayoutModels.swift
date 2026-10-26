import Foundation
import CoreGraphics

/// A window captured at a point in time, stored relative to the display it was on.
struct SavedWindow: Codable, Identifiable, Hashable {
    var id = UUID()
    let bundleID: String
    let appName: String
    let title: String
    /// Order among the app's standard windows at capture time (fallback match).
    let index: Int
    /// Hardware UUID of the display containing most of the window.
    let displayUUID: String
    /// Window origin relative to the display origin (top-left, AX coordinates).
    let relativeOrigin: CGPoint
    let size: CGSize
}

/// A named collection of saved windows plus the displays present when it was captured.
struct SavedLayout: Codable, Identifiable, Hashable {
    var id = UUID()
    var name: String
    let date: Date
    let displayUUIDs: [String]
    var windows: [SavedWindow]
}
