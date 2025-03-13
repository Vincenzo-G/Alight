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

// View che crea l'effetto gradient overlay, passando dal bianco al colore della forma
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

struct ContentView: View {
    
    @StateObject private var homeManager = HomeManager()
    @AppStorage("isOnboardingShowing") private var isOnboardingShowing = true
    
    @Environment(\.colorScheme) var colorScheme
    // Stato per la forma centrale.
    // Idle: "circle" (cerchio con stroke)
    @State private var selectedShape: String = "circle"
    @State private var selectedColor: Color = .white
    // Identifica il pulsante attivo (basato sul titolo)
    @State private var activeButton: String? = nil
    @State private var isOptionsShowing = false  // Per il menu opzioni
    
    // Funzione per attivare l'haptic feedback
    func triggerHapticFeedback() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Background dinamico
            Color(colorScheme == .light ? Color(hex: "E5E5EA") : Color(hex: "1C1C1E"))
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                // Vista centrale: se lo stato è idle non c'è animazione,
                // altrimenti l'animazione pulsante parte ogni volta che la forma cambia.
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
                                    color: Color(hex: "E89D00"),
                                    isActive: activeButton == "Doorbell",
                                    anyButtonActive: activeButton != nil) {
                        guard activeButton == nil else { return }
                        triggerHapticFeedback()
                        triggerHapticFeedback()
                        homeManager.flashLights(button: "Button 1", cycles: 3, colorHue: 40)
                        withAnimation(.easeInOut(duration: 0.5)) {
                            activeButton = "Doorbell"
                            selectedShape = "circle.fill"
                            selectedColor = Color(hex: "E89D00")
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 20) {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                selectedShape = "circle"
                                activeButton = nil
                            }
                        }
                    }
                    
                    AnimationButton(title: "Meal",
                                    primaryIcon: "fork.knife",
                                    shapeIcon: "square.fill",
                                    color: Color(hex: "24709F"),
                                    isActive: activeButton == "Meal",
                                    anyButtonActive: activeButton != nil) {
                        guard activeButton == nil else { return }
                        triggerHapticFeedback()
                        triggerHapticFeedback()
                        homeManager.flashLights(button: "Button 2", cycles: 3, colorHue: 240)
                        withAnimation(.easeInOut(duration: 0.5)) {
                            activeButton = "Meal"
                            selectedShape = "square.fill"
                            selectedColor = Color(hex: "24709F")
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 20) {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                selectedShape = "circle"
                                activeButton = nil
                            }
                        }
                    }
                    
                    AnimationButton(title: "Alert",
                                    primaryIcon: "light.beacon.max.fill",
                                    shapeIcon: "triangle.fill",
                                    color: Color(hex: "B23837"),
                                    isActive: activeButton == "Alert",
                                    anyButtonActive: activeButton != nil) {
                        guard activeButton == nil else { return }
                        triggerHapticFeedback()
                        triggerHapticFeedback()
                        homeManager.flashLights(button: "Button 3", cycles: 3, colorHue: 0)
                        withAnimation(.easeInOut(duration: 0.5)) {
                            activeButton = "Alert"
                            selectedShape = "triangle.fill"
                            selectedColor = Color(hex: "B23837")
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 20) {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                selectedShape = "circle"
                                activeButton = nil
                            }
                        }
                    }
                    
                    AnimationButton(title: "Approach",
                                    primaryIcon: "figure.walk",
                                    shapeIcon: "pentagon.fill",
                                    color: Color(hex: "237F52"),
                                    isActive: activeButton == "Approach",
                                    anyButtonActive: activeButton != nil) {
                        guard activeButton == nil else { return }
                        triggerHapticFeedback()
                        triggerHapticFeedback()
                        homeManager.flashLights(button: "Button 4", cycles: 3, colorHue: 120)
                        withAnimation(.easeInOut(duration: 0.5)) {
                            activeButton = "Approach"
                            selectedShape = "pentagon.fill"
                            selectedColor = Color(hex: "237F52")
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 20) {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                selectedShape = "circle"
                                activeButton = nil
                            }
                        }
                    }
                }
                .padding()
                
            }
            .padding(.top, 40)
            
            // Bottone settings, sempre abilitato
            Button(action: {
                isOptionsShowing = true
            }) {
                Image(systemName: "ellipsis")
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .padding(30)
                    .font(.largeTitle)
            }
            .sheet(isPresented: $isOptionsShowing) {
                OptionsView()
                
            }
            .sheet(isPresented: $isOnboardingShowing) {
                OnboardingView(isOnboardingShowing: $isOnboardingShowing)
            }

            
        }
    }
}

// Vista per la forma centrale
struct PulsingShapeView: View {
    let shapeSymbol: String
    let color: Color
    @State private var pulse = false
    
    var body: some View {
        Group {
            if shapeSymbol == "circle" {
                // Stato idle: cerchio statico con stroke di 10, senza animazione
                Circle()
                    .stroke(Color(hex: "BDBDBD"), lineWidth: 10)
                    .aspectRatio(contentMode: .fit)
            } else {
                // Stato animato: l'immagine pulsa, con overlay di pulse e overlay gradient
                Image(systemName: shapeSymbol)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(color)
                    .scaleEffect(pulse ? 1.1 : 1.0)
                    .shadow(color: color.opacity(pulse ? 0.9 : 0.3), radius: pulse ? 20 : 10)
                    .overlay(PulseAnimationOverlay(shapeSymbol: shapeSymbol, color: color))
                    .overlay(GradientOverlay(shapeSymbol: shapeSymbol, baseColor: color, pulse: pulse))
                    .onAppear { startAnimation() }
            }
        }
    }
    
    private func startAnimation() {
        pulse = false
        withAnimation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
            pulse = true
        }
    }
}

// View che crea l'effetto pulse overlay, utilizzando lo stesso SF Symbol e colore
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

// Componente per ciascun pulsante
struct AnimationButton: View {
    @Environment(\.colorScheme) var colorScheme
    
    let title: String
    let primaryIcon: String
    let shapeIcon: String
    let color: Color
    let isActive: Bool
    let anyButtonActive: Bool
    let action: () -> Void
    
    var dynamicTextColor: Color {
        isActive ? .white : (colorScheme == .dark ? .white : .black)
    }
    
    var dynamicButtonBackground: Color {
        isActive ? color : (colorScheme == .light ? Color(hex: "FFFFFF") : Color(UIColor.systemGray4))
    }
    
    var body: some View {
        Button(action: action) {
            VStack {
                // Icona in alto a sinistra
                HStack {
                    Image(systemName: primaryIcon)
                        .font(.largeTitle)
                        .foregroundColor(dynamicTextColor)
                    Spacer()
                }
                .padding(.top, 10)
                
                Spacer()
                
                // Testo in basso a sinistra e icona della forma in basso a destra
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
        .disabled(anyButtonActive && !isActive)
    }
}


#Preview {
    ContentView()
}
