//
//  PulseAnimationOverlay.swift
//  Alight!
//
//  Created by Gennaro Liguori on 19/03/25.
//

import SwiftUI


struct PulseAnimationOverlay: View {
    let shapeSymbol: String
    let color: Color
    @State private var enablePulse = false
    
    var body: some View {
        Image(systemName: shapeSymbol)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundColor(color)
            .opacity(enablePulse ? 0 : 0.3)
            .scaleEffect(enablePulse ? 3 : 1)
            .blur(radius: enablePulse ? 2 : 0)
            .onAppear {
                withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                    enablePulse = true
                }
            }
    }
}
