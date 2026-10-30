import SwiftUI

@main struct MyApp: App {
    @State private var store = LayoutStore()

    var body: some Scene {
        Window("Window Memory", id: MenuBarContent.windowID) {
            ContentView()
                .environment(store)
                // Show in the Dock only while the window is open; closing it leaves the menu bar item running.
                .onAppear { NSApp.setActivationPolicy(.regular) }
                .onDisappear { NSApp.setActivationPolicy(.accessory) }
        }

        MenuBarExtra("Window Memory", systemImage: "rectangle.3.group") {
            MenuBarContent()
                .environment(store)
        }
    }
}

/// Contents of the menu bar menu: open window, apply a profile, quit.
struct MenuBarContent: View {
    static let windowID = "main"

    @Environment(LayoutStore.self) private var store
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        Button("Abrir ventana") {
            openWindow(id: Self.windowID)
            NSApp.activate()
        }

        Divider()

        Section("Aplicar perfil") {
            ForEach(store.layouts) { layout in
                Button(layout.name) { store.restore(layout) }
            }
            if store.layouts.isEmpty {
                Text("Sin perfiles guardados")
            }
        }

        Divider()

        Button("Salir") { NSApplication.shared.terminate(nil) }
            .keyboardShortcut("q")
    }
}
