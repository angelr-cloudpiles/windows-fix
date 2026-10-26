import SwiftUI

/// Holds saved layouts, persists them as JSON and drives capture/restore.
@Observable
final class LayoutStore {
    private(set) var layouts: [SavedLayout] = []
    private(set) var isTrusted = WindowService.isTrusted
    var status = ""

    private let fileURL: URL = {
        let base = URL.applicationSupportDirectory.appending(path: "WindowMemory", directoryHint: .isDirectory)
        try? FileManager.default.createDirectory(at: base, withIntermediateDirectories: true)
        return base.appending(path: "layouts.json")
    }()

    init() { load() }

    func refreshTrust() { isTrusted = WindowService.isTrusted }

    func requestAccessibility() {
        WindowService.requestTrust()
        refreshTrust()
    }

    func saveCurrentLayout(named name: String) {
        guard WindowService.isTrusted else { refreshTrust(); status = "Falta el permiso de Accesibilidad."; return }
        let windows = WindowService.captureWindows()
        let displays = DisplayInfo.connected().map(\.uuid)
        let finalName = name.trimmingCharacters(in: .whitespaces).isEmpty ? "Layout \(layouts.count + 1)" : name
        layouts.insert(SavedLayout(name: finalName, date: .now, displayUUIDs: displays, windows: windows), at: 0)
        status = "Guardadas \(windows.count) ventanas en \(displays.count) monitor(es)."
        persist()
    }

    func restore(_ layout: SavedLayout) {
        guard WindowService.isTrusted else { refreshTrust(); status = "Falta el permiso de Accesibilidad."; return }
        let result = WindowService.restore(layout)
        status = "Restauradas \(result.restored) ventanas, omitidas \(result.skipped)."
    }

    func delete(_ layout: SavedLayout) {
        layouts.removeAll { $0.id == layout.id }
        persist()
    }

    // MARK: Persistence

    private func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode([SavedLayout].self, from: data) else { return }
        layouts = decoded
    }

    private func persist() {
        do {
            try JSONEncoder().encode(layouts).write(to: fileURL, options: .atomic)
        } catch {
            status = "No se pudo guardar: \(error.localizedDescription)"
        }
    }
}
