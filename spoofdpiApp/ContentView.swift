import SwiftUI

struct ContentView: View {
    @ObservedObject var manager: SpoofDPIManager
    @Environment(\.openWindow) private var openWindow
    
    @State private var showErrorAlert = false
    @State private var errorMessage = ""

    var body: some View {
        ZStack(alignment: .center) {
            BackgroundView()
            
            VStack(spacing: 20) {
                Spacer()
                
                HStack {
                    Toggle("", isOn: $manager.isRunning)
                        .toggleStyle(CustomToggleStyle())
                }
                .padding()
                
                Text(manager.isRunning ? "Click to turn it off" : "Click to turn it on")
                    .font(.caption)
                
                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button("Settings", systemImage: "gear") {
                        openWindow(id: "settings")
                    }
                    
                }
            }
        }
        .onChange(of: manager.error) { _, newError in
            if let newError = newError {
                errorMessage = newError
                showErrorAlert = true
            }
        }
        .alert("Error", isPresented: $showErrorAlert) {
            Button("OK") {
                manager.error = nil
            }
        } message: {
            Text(errorMessage)
        }
    }
    
}

#Preview {
    ContentView(manager: SpoofDPIManager())
}
