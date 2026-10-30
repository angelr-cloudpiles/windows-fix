import SwiftUI

/// Edits which windows belong to a layout: enable/disable, remove, or add open windows.
struct LayoutEditorView: View {
    @Environment(LayoutStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    let layoutID: SavedLayout.ID

    @State private var available: [SavedWindow] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let layout = store.layout(withID: layoutID) {
                TextField("Nombre", text: Binding(
                    get: { layout.name },
                    set: { store.rename(layoutID, to: $0) }
                ))
                .font(.headline)

                List {
                    Section("En este layout") {
                        ForEach(layout.windows) { window in
                            HStack {
                                Toggle(isOn: Binding(
                                    get: { window.isEnabled },
                                    set: { store.setWindow(window.id, enabled: $0, in: layoutID) }
                                )) {
                                    windowLabel(window)
                                }
                                Button(role: .destructive) {
                                    store.removeWindow(window.id, from: layoutID)
                                    reloadAvailable()
                                } label: { Image(systemName: "trash") }
                                .buttonStyle(.borderless)
                            }
                        }
                    }

                    Section {
                        ForEach(available) { window in
                            HStack {
                                windowLabel(window)
                                Spacer()
                                Button {
                                    store.add([window], to: layoutID)
                                    reloadAvailable()
                                } label: { Image(systemName: "plus.circle") }
                                .buttonStyle(.borderless)
                            }
                        }
                        if available.isEmpty {
                            Text("No hay otras ventanas abiertas.").foregroundStyle(.secondary)
                        }
                    } header: {
                        HStack {
                            Text("Ventanas abiertas")
                            Spacer()
                            Button("Actualizar", action: reloadAvailable).buttonStyle(.link)
                        }
                    }
                }
            } else {
                ContentUnavailableView("Layout no encontrado", systemImage: "questionmark.folder")
            }

            HStack {
                Spacer()
                Button("Listo") { dismiss() }.keyboardShortcut(.defaultAction)
            }
        }
        .padding()
        .frame(minWidth: 520, minHeight: 460)
        .onAppear(perform: reloadAvailable)
    }

    private func windowLabel(_ window: SavedWindow) -> some View {
        VStack(alignment: .leading) {
            Text(window.appName)
            Text(window.title.isEmpty ? "(sin título)" : window.title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
    }

    private func reloadAvailable() {
        available = store.availableWindows(for: layoutID)
    }
}
