//
//  ContentView.swift
//  Alight!
//
//  Created by Vincenzo Gerelli on 12/03/25.
//

import SwiftUI

// Estensione per creare un Color da una stringa esadecimale
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RRGGBB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // AARRGGBB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    // Stato che controlla la forma e il colore visualizzati al centro
    // Stato idle: "circle" (cerchio con stroke) e colore idle impostato a BDBDBD per il contorno
    @State private var selectedShape: String = "circle"
    @State private var selectedColor: Color = .white
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack {
                Spacer()
                
                // Vista centrale: forma grande con animazione pulsante se non in idle
                PulsingShapeView(shapeSymbol: selectedShape, color: selectedColor)
                    .frame(width: 300, height: 300)
                
                Spacer()
                
                // Griglia con 4 pulsanti
                
                LazyVGrid(columns: [GridItem(.flexible()),
                                     GridItem(.flexible())],
                          spacing: 10) {
                    
                    AnimationButton(title: "Doorbell",
                                    primaryIcon: "bell.fill",
                                    shapeIcon: "circle.fill",
                                    color: Color(hex: "E89D00")) {
                        selectedShape = "circle.fill"
                        selectedColor = Color(hex: "E89D00")
                    }
                    
                    AnimationButton(title: "Meal",
                                    primaryIcon: "fork.knife",
                                    shapeIcon: "square.fill",
                                    color: Color(hex: "24709F")) {
                        selectedShape = "square.fill"
                        selectedColor = Color(hex: "24709F")
                    }
                    
                    AnimationButton(title: "Alert",
                                    primaryIcon: "light.beacon.max.fill",
                                    shapeIcon: "triangle.fill",
                                    color: Color(hex: "B23837")) {
                        selectedShape = "triangle.fill"
                        selectedColor = Color(hex: "B23837")
                    }
                    
                    AnimationButton(title: "Approaching",
                                    primaryIcon: "figure.walk",
                                    shapeIcon: "pentagon.fill",
                                    color: Color(hex: "237F52")) {
                        selectedShape = "pentagon.fill"
                        selectedColor = Color(hex: "237F52")
                    }
                    
                }
                .padding()
                
                Spacer()
            }
            .padding(.top, 40)
            
            // Bottone per i settings con colore dinamico
            Button(action: {
                // Azione per aprire i settings
            }) {
                Image(systemName: "ellipsis")
                    .padding(50)
                    .font(.largeTitle)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
            }
            
        }
        
       
        // Background dinamico: in light mode usa E5E5EA, altrimenti 1C1C1E
        .background(colorScheme == .light ? Color(hex: "E5E5EA") : Color(hex: "1C1C1E"))
        .ignoresSafeArea()
    }
}

// Vista che mostra la forma al centro
struct PulsingShapeView: View {
    let shapeSymbol: String
    let color: Color
    @State private var pulse = false
    
    var body: some View {
        Group {
            if shapeSymbol == "circle" {
                // Stato idle: disegna un cerchio con stroke di 10 e colore BDBDBD
                Circle()
                    .stroke(Color(hex: "BDBDBD"), lineWidth: 10)
                    .aspectRatio(contentMode: .fit)
            } else {
                // Stato animato: la forma pulsa e assume il colore specificato
                Image(systemName: shapeSymbol)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(color)
                    .scaleEffect(pulse ? 1.2 : 1.0)
                    .animation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: pulse)
                    .onAppear {
                        pulse = true
                    }
            }
        }
    }
}

// Componente per ciascun pulsante con layout personalizzato:
// - Icona in alto a sinistra
// - Testo in basso a sinistra
// - Icona della forma in basso a destra
struct AnimationButton: View {
    @Environment(\.colorScheme) var colorScheme
    
    let title: String
    let primaryIcon: String
    let shapeIcon: String
    let color: Color
    let action: () -> Void
    
    // Colore dinamico per testo e icona principale
    var dynamicTextColor: Color {
        colorScheme == .dark ? .white : .black
    }
    
    // Background dinamico per il tasto: in light mode usa FFFFFF, altrimenti systemGray4
    var dynamicButtonBackground: Color {
        colorScheme == .light ? Color(hex: "FFFFFF") : Color(UIColor.systemGray4)
    }
    
    var body: some View {
        Button(action: action) {
            VStack {
                HStack {
                    Image(systemName: primaryIcon)
                        .font(.largeTitle)
                        .foregroundColor(dynamicTextColor)
                    Spacer()
                }
                .padding(.top, 10)
                Spacer()
                HStack {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(dynamicTextColor)
                    Spacer()
                    Image(systemName: shapeIcon)
                        .font(.title)
                        .foregroundColor(color)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, minHeight: 150)
            .background(dynamicButtonBackground)
            .cornerRadius(20)
        }
    }
}

#Preview {
    ContentView()
}
