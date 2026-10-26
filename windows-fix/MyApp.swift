import SwiftUI

@main struct MyApp: App {
    @State private var store = LayoutStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(store)
        }

        MenuBarExtra("Window Memory", systemImage: "rectangle.3.group") {
            ForEach(store.layouts) { layout in
                Button("Restaurar \(layout.name)") { store.restore(layout) }
            }
            if store.layouts.isEmpty { Text("Sin layouts guardados") }
        }
    }
}
