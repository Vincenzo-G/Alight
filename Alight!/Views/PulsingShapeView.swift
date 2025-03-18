//
//  PulsingShapeView.swift
//  Alight!
//
//  Created by Gennaro Liguori on 19/03/25.
//

import SwiftUI

struct PulsingShapeView: View {
    let shapeSymbol: String
    let color: Color

    // Stato per la pulsazione nelle forme diverse dal cerchio idle
    @State private var pulse = false
    // Stato per il rimbalzo one-shot del cerchio idle
    @State private var idleBounce = false
    // Stato per tenere traccia dell'ultima forma mostrata
    @State private var lastShape: String = "circle"
    
    var body: some View {
        ZStack {
            if shapeSymbol == "circle" {
                Circle()
                    .stroke(Color(hex: "BDBDBD"), lineWidth: 15)
                    .frame(width: 330, height: 330)
                    .scaleEffect(idleBounce ? 1.05 : 1.0)
                    .onAppear {
                        if lastShape != "circle" {
                            withAnimation(Animation.interpolatingSpring(stiffness: 100, damping: 10)) {
                                idleBounce = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                withAnimation(Animation.interpolatingSpring(stiffness: 100, damping: 10)) {
                                    idleBounce = false
                                }
                            }
                        }
                        lastShape = "circle"
                    }
            } else {
                Image(systemName: shapeSymbol)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(color)
                    .scaleEffect(pulse ? 1.1 : 1.0)
                    .shadow(color: color.opacity(pulse ? 0.9 : 0.3), radius: pulse ? 20 : 10)
                    .overlay(PulseAnimationOverlay(shapeSymbol: shapeSymbol, color: color))
                    .overlay(GradientOverlay(shapeSymbol: shapeSymbol, baseColor: color, pulse: pulse))
                    .transition(.asymmetric(insertion: .scale, removal: .scale))
                    .onAppear {
                        pulse = false
                        withAnimation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                            pulse = true
                        }
                        lastShape = shapeSymbol
                    }
            }
        }
        .transition(.scale)
        .id(shapeSymbol)
        .animation(.interpolatingSpring(stiffness: 40, damping: 100), value: shapeSymbol)
    }
}
