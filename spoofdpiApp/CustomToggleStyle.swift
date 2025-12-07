//
//  CustomToggleStyle.swift
//  spoofdpiApp
//
//  Created by Maksim Gritsuk on 04.12.2025.
//

import Foundation
import SwiftUI


struct CustomToggleStyle: ToggleStyle {
    
    @AppStorage("userAccentColorHex") private var accentHex = "#34C759"
    
    func makeBody(configuration: Configuration) -> some View {
        RoundedRectangle(cornerRadius: 36)
            .frame(width: 150, height: 75)
            .foregroundColor(configuration.isOn ? Color(hex: accentHex) : .black)
            .overlay(
                Circle()
                    .fill(.white)
                    .padding(4)
                    .offset(x: configuration.isOn ? 36 : -36)
            )
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.25)) {
                    configuration.isOn.toggle()
                }
            }
            .contentShape(Rectangle())
    }
}
