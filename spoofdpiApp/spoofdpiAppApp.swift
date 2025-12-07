import SwiftUI

@main
struct spoofdpiAppApp: App {

    @StateObject private var manager = SpoofDPIManager()
    @Environment(\.openWindow) private var openWindow

    @AppStorage("colorTheme") var selectedTheme: Theme = .automatic
    @AppStorage("isOn") var isOn: Bool = false
    @AppStorage("hidesDockIcon") private var hidesDockIcon = false

    var body: some Scene {
        WindowGroup("SpoofDPI", id: "app") {
            ContentView(manager: manager)
                .onAppear {
                    manager.installIfNeeded()
                }
                .preferredColorScheme(
                    selectedTheme == .automatic
                        ? nil : (selectedTheme == .light ? .light : .dark)
                )
        }
        .commands {
            CommandGroup(after: .appSettings) {
                Button("Settings…") {
                    openWindow(id: "settings")
                }
                .keyboardShortcut(",", modifiers: .command)
            }
        }

        WindowGroup("Settings", id: "settings") {
            SettingsView()
                .preferredColorScheme(
                    selectedTheme == .automatic
                        ? nil : (selectedTheme == .light ? .light : .dark)
                )
        }
        .windowResizability(.contentSize)

        MenuBarExtra("", systemImage: isOn ? "network" : "network.slash") {
            Button(isOn ? "Stop" : "Start") {
                if isOn {
                    manager.stopProxy()
                } else {
                    manager.startProxy()
                }
            }
            Divider()
            Button("SpoodDPI") {
                openWindow(id: "app")
            }
            Button("Settings") {
                openWindow(id: "settings")
            }
            Button("Quit") {
                NSApp.terminate(nil)
            }
        }

    }
}
