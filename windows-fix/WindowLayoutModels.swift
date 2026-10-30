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
    /// Disabled windows stay in the layout but are ignored on restore.
    var isEnabled = true
}

extension SavedWindow {
    /// Custom decoding so layouts saved before `isEnabled` existed still load.
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        bundleID = try c.decode(String.self, forKey: .bundleID)
        appName = try c.decode(String.self, forKey: .appName)
        title = try c.decode(String.self, forKey: .title)
        index = try c.decode(Int.self, forKey: .index)
        displayUUID = try c.decode(String.self, forKey: .displayUUID)
        relativeOrigin = try c.decode(CGPoint.self, forKey: .relativeOrigin)
        size = try c.decode(CGSize.self, forKey: .size)
        isEnabled = try c.decodeIfPresent(Bool.self, forKey: .isEnabled) ?? true
    }

    /// True when `other` describes the same window (same app and title, or same slot if untitled).
    func matches(_ other: SavedWindow) -> Bool {
        bundleID == other.bundleID && (title.isEmpty ? index == other.index && other.title.isEmpty : title == other.title)
    }
}

/// A named collection of saved windows plus the displays present when it was captured.
struct SavedLayout: Codable, Identifiable, Hashable {
    var id = UUID()
    var name: String
    let date: Date
    let displayUUIDs: [String]
    var windows: [SavedWindow]
}
