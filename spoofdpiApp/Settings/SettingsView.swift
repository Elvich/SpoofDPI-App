//
//  SettingsView.swift
//  spoofdpiApp
//
//  Created by Maksim Gritsuk on 04.12.2025.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        TabView {
            Tab("Network", systemImage: "network") {
                NetworkSettingsView()
            }
            
            Tab("App", systemImage: "person"){
                AppSettingsView()
            }
            
            Tab("Visual", systemImage: "paintpalette") {
                VisualSettingsView()
            }
        }
        .tabViewStyle(.automatic)
        .scenePadding()
        .frame(minHeight: 100)
    }
}

#Preview {
    SettingsView()
}
