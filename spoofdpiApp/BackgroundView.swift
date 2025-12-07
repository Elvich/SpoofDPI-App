//
//  BackgroundView.swift
//  spoofdpiApp
//
//  Created by Maksim Gritsuk on 04.12.2025.
//

import SwiftUI

struct BackgroundView: View {
    @AppStorage("userAccentColorHex") private var accentHex = "#34C759"
    
    private let asciiLines = [
        ".d8888b.                              .d888  8888888b.  8888888b. 8888888",
        "d88P  Y88b                            d88P'  888  'Y88b 888   Y88b  888  ",
        "Y88b.                                 888    888    888 888    888  888  ",
        " 'Y888b.   88888b.   .d88b.   .d88b.  888888 888    888 888   d88P  888  ",
        "    'Y88b. 888 '88b d88''88b d88''88b 888    888    888 8888888P'   888  ",
        "      '888 888  888 888  888 888  888 888    888    888 888         888  ",
        "Y88b  d88P 888 d88P Y88..88P Y88..88P 888    888  .d88P 888         888  ",
        " 'Y8888P'  88888P'   'Y88P'   'Y88P'  888    8888888P'  888       8888888",
        "           888                                                           ",
        "           888                                                           ",
        "           888                                                           ",
    ]
    
    var body: some View {
        
        let color: Color = Color(hex: accentHex)!
        
        VStack(spacing: -4) {
            ForEach(asciiLines.indices, id: \.self) { index in
                HStack {
                    Spacer()
                    Text(asciiLines[index])
                        .font(.system(size: 18, design: .monospaced))
                        .foregroundColor(color.opacity(0.5))
                        .lineLimit(nil)
                        .padding(.vertical, 4)
                    Spacer()
                }
            }
        }
        .padding()
        .allowsHitTesting(false)
    }
}

#Preview {
    BackgroundView()
}
