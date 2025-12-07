//
//  AppSettingsView.swift
//  spoofdpiApp
//
//  Created by Maksim Gritsuk on 07.12.2025.
//

import SwiftUI

struct AppSettingsView: View {
    @AppStorage("hidesDockIcon") private var hidesDockIcon = false

    var body: some View {
        List {
            HStack {
                Text("Hide icon in dock")
                Spacer()
                Toggle("", isOn: $hidesDockIcon)
                    .onChange(of: hidesDockIcon) { _, newValue in
                        updateDockIconVisibility(hides: newValue)
                    }
                    .toggleStyle(.switch)
            }
        }
    }

    private func updateDockIconVisibility(hides: Bool) {
        let policy: NSApplication.ActivationPolicy =
            hides ? .accessory : .regular
        NSApp.setActivationPolicy(policy)
    }
}

#Preview {
    AppSettingsView()
}
