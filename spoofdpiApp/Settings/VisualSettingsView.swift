//
//  VisualSettingsView.swift
//  spoofdpiApp
//
//  Created by Maksim Gritsuk on 04.12.2025.
//

import SwiftUI

struct VisualSettingsView: View {
    @AppStorage("userAccentColorHex") private var accentHex = "#34C759"
    @State private var selectedColor = Color.accentColor

    @AppStorage("colorTheme") private var selectedTheme: Theme = .automatic

    var body: some View {
        List {
            ColorPicker("Accent Color", selection: $selectedColor)
                .onChange(of: selectedColor) {
                    if let hex = selectedColor.toHex() {
                        accentHex = hex
                    }
                }
                .onAppear {
                    if let savedColor = Color(hex: accentHex) {
                        selectedColor = savedColor
                    }
                }
            
            
            Form {
                Picker("Appearance", selection: $selectedTheme) {
                    ForEach(Theme.allCases) { theme in
                        Text(theme.localizedName)
                            .tag(theme)
                    }
                }
                .pickerStyle(MenuPickerStyle()) 
            }
        }
    }
}

enum Theme: Int, CaseIterable, Identifiable {
    case light, dark, automatic

    var id: Int { rawValue }

    var localizedName: String {
        switch self {
        case .light: return "Light"
        case .dark: return "Dark"
        case .automatic: return "Automatic"
        }
    }
}

#Preview {
    VisualSettingsView()
}
