//
//  NetworkSettingsView.swift
//  spoofdpiApp
//
//  Created by Maksim Gritsuk on 04.12.2025.
//

import SwiftUI

struct NetworkSettingsView: View {
    @AppStorage("windowSize") private var windowSize = 1

    @State private var windowSizeFormatted: String = ""

    var body: some View {
        List {
            HStack {
                Text("Window size:")
                Spacer()
                TextField("0", text: $windowSizeFormatted)
                    .onChange(of: windowSizeFormatted) { _, new in
                        if let newValue = Int(new) {
                            windowSize = newValue
                        }
                        windowSizeFormatted = "\(windowSize)"
                    }
                    .onAppear {
                        windowSizeFormatted = "\(windowSize)"
                    }
            }
        }
    }
}

#Preview {
    NetworkSettingsView()
}
