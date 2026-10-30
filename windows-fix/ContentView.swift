import SwiftUI

struct ContentView: View {
    @Environment(LayoutStore.self) private var store
    @State private var newName = ""
    @State private var editing: SavedLayout?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !store.isTrusted {
                HStack {
                    Label("Se necesita permiso de Accesibilidad para mover ventanas.", systemImage: "exclamationmark.triangle")
                    Spacer()
                    Button("Conceder acceso") { store.requestAccessibility() }
                }
                .padding(8)
                .background(.yellow.opacity(0.2), in: .rect(cornerRadius: 8))
            }

            HStack {
                TextField("Nombre del layout", text: $newName)
                    .onSubmit(save)
                Button("Guardar ventanas actuales", action: save)
            }

            List {
                ForEach(store.layouts) { layout in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(layout.name).font(.headline)
                            Text("\(layout.windows.filter(\.isEnabled).count)/\(layout.windows.count) ventanas · \(layout.displayUUIDs.count) monitor(es) · \(layout.date.formatted(date: .abbreviated, time: .shortened))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Button("Editar") { editing = layout }
                        Button("Restaurar") { store.restore(layout) }
                        Button(role: .destructive) { store.delete(layout) } label: {
                            Image(systemName: "trash")
                        }
                    }
                }
            }
            .overlay {
                if store.layouts.isEmpty {
                    ContentUnavailableView("Sin layouts", systemImage: "rectangle.on.rectangle",
                                           description: Text("Acomoda tus ventanas y guarda un layout."))
                }
            }

            Text(store.status).font(.caption).foregroundStyle(.secondary)
        }
        .padding()
        .frame(minWidth: 520, minHeight: 360)
        .sheet(item: $editing) { layout in
            // The editor reads live data from the store by ID; `layout` only identifies it.
            LayoutEditorView(layoutID: layout.id)
        }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
            store.refreshTrust()
        }
    }

    private func save() {
        store.saveCurrentLayout(named: newName)
        newName = ""
    }
}

#Preview {
    ContentView()
        .environment(LayoutStore())
}
