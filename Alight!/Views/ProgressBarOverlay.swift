//
//  ProgressBarOverlay.swift
//  Alight!
//
//  Created by Gennaro Liguori on 19/03/25.
//

import SwiftUI


struct ProgressBarOverlay: View {
    @Binding var progress: Double  // 1.0 = barra piena, 0.0 = vuota
    let activeColor: Color

    var body: some View {
        GeometryReader { geometry in
            Rectangle()
                .fill(activeColor)
                .frame(width: geometry.size.width * progress)
                .animation(.linear(duration: 0.01), value: progress)
                .frame(maxHeight: .infinity, alignment: .leading)
        }
        .clipped()
    }
}
