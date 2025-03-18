//
//  GradientOverlay.swift
//  Alight!
//
//  Created by Gennaro Liguori on 19/03/25.
//
import SwiftUI

struct GradientOverlay: View {
    let shapeSymbol: String
    let baseColor: Color
    let pulse: Bool
    
    var body: some View {
        Image(systemName: shapeSymbol)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundStyle(
                LinearGradient(
                    gradient: Gradient(colors: [Color.white, baseColor]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .scaleEffect(pulse ? 1.1 : 1.0)
            .opacity(0.5)
    }
}
