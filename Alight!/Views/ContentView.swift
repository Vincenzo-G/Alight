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

// Vista per la forma centrale
struct PulsingShapeView: View {
    let shapeSymbol: String
    let color: Color
    @State private var pulse = false

    var body: some View {
        ZStack {
            if shapeSymbol == "circle" {
                // Stato idle: il cerchio che, in uscita, si riduce a zero
                Circle()
                    .stroke(Color(hex: "BDBDBD"), lineWidth: 15)
                    .frame(width: 330, height: 330)
                    .transition(.asymmetric(insertion: .scale, removal: .scale))
            } else {
                // Stato attivo: la nuova forma che appare crescendo da zero
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
                        startAnimation()
                    }
            }
        }
        // Animazione della transizione basata sul cambiamento di shapeSymbol
        .animation(.easeInOut(duration: 0.5), value: shapeSymbol)
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
    
    let buttonID: String
    let primaryIcon: String
    let shapeIcon: String
    let color: Color
    let isActive: Bool
    let anyButtonActive: Bool
    let action: () -> Void
    
    @State private var isOptionsShowing = false
    @State private var buttonName: String

    // Nomi di default per ciascun pulsante
    private let defaultNames: [String: String] = [
        "Button 1": "Doorbell",
        "Button 2": "Meal",
        "Button 3": "Alert",
        "Button 4": "Approach"
    ]
    
    init(buttonID: String, primaryIcon: String, shapeIcon: String, color: Color, isActive: Bool, anyButtonActive: Bool, action: @escaping () -> Void) {
        self.buttonID = buttonID
        self.primaryIcon = primaryIcon
        self.shapeIcon = shapeIcon
        self.color = color
        self.isActive = isActive
        self.anyButtonActive = anyButtonActive
        self.action = action
        
        // Controlla UserDefaults o usa il nome di default
        let storedName = UserDefaults.standard.string(forKey: "buttonName_\(buttonID)")
            ?? defaultNames[buttonID]
            ?? buttonID  // Fallback se non esiste un default
        _buttonName = State(initialValue: storedName)
    }
    
    // Se un pulsante non è attivo e un altro è attivo, il testo diventa grigio
    var dynamicTextColor: Color {
        if anyButtonActive && !isActive {
            return Color.gray
        } else {
            return isActive ? .white : (colorScheme == .dark ? .white : .black)
        }
    }
    
    // Se un pulsante non è attivo e un altro è attivo, anche l'icona della forma diventa grigia
    var dynamicShapeIconColor: Color {
        if anyButtonActive && !isActive {
            return Color.gray
        } else {
            return color
        }
    }
    
    var dynamicButtonBackground: Color {
        if anyButtonActive && !isActive {
            return Color.gray.opacity(0.3)
        } else {
            return isActive ? color : (colorScheme == .light ? Color(hex: "FFFFFF") : Color(UIColor.systemGray4))
        }
    }
    
    var body: some View {
        Button(action: action) {
            VStack {
                HStack {
                    Image(systemName: primaryIcon)
                        .font(.largeTitle)
                        .foregroundColor(dynamicTextColor)
                    Spacer()
                    
                    // Pulsante "Three Dots" per aprire OptionsView
                    Button(action: {
                        isOptionsShowing = true
                    }) {
                        Image(systemName: "ellipsis")
                            .font(.title2)
                            .foregroundColor(dynamicTextColor.opacity(0.7))
                    }
                    .disabled(anyButtonActive && !isActive)
                }
                .padding(.top, 10)
                
                Spacer()
                
                // Sezione inferiore: titolo + icona della forma
                HStack {
                    Text(buttonName)
                        .font(.headline)
                        .foregroundColor(dynamicTextColor)
                    Spacer()
                    Image(systemName: shapeIcon)
                        .font(.title)
                        .foregroundColor(dynamicShapeIconColor)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, minHeight: 150)
            .background(dynamicButtonBackground)
            .cornerRadius(20)
        }
        .disabled(anyButtonActive && !isActive)
        .sheet(isPresented: $isOptionsShowing, onDismiss: {
            // Aggiorna il nome del pulsante dopo la chiusura di OptionsView
            buttonName = UserDefaults.standard.string(forKey: "buttonName_\(buttonID)")
                ?? defaultNames[buttonID]
                ?? buttonID
        }) {
            NavigationView {
                OptionsView(buttonID: buttonID)
            }
        }
    }
}

// Vista principale
struct ContentView: View {
    
    @StateObject private var homeManager = HomeManager()
    @AppStorage("isOnboardingShowing") private var isOnboardingShowing = true
    
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedShape: String = "circle"
    @State private var selectedColor: Color = .white
    @State private var activeButton: String? = nil
    @State private var animationWorkItem: DispatchWorkItem? = nil  // Variabile per gestire il blocco programmato
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color(colorScheme == .light ? Color(hex: "E5E5EA") : Color(hex: "1C1C1E"))
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                PulsingShapeView(shapeSymbol: selectedShape, color: selectedColor)
                    .frame(width: 300, height: 300)
                
                Spacer()
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    
                    // Pulsante 1
                    AnimationButton(buttonID: "Button 1",
                                    primaryIcon: "bell.fill",
                                    shapeIcon: "circle.fill",
                                    color: Color(hex: "E89D00"),
                                    isActive: activeButton == "Doorbell",
                                    anyButtonActive: activeButton != nil) {
                        if activeButton == "Doorbell" {
                            // Se il pulsante attivo viene ripremuto, annulla il blocco programmato e torna in stato idle
                            animationWorkItem?.cancel()
                            animationWorkItem = nil
                            withAnimation(.easeInOut(duration: 0.5)) {
                                selectedShape = "circle"
                                activeButton = nil
                            }
                            return
                        }
                        
                        // Attiva l'animazione
                        homeManager.flashLights(button: "Button 1", colorHue: 40)
                        withAnimation(.easeInOut(duration: 0.5)) {
                            activeButton = "Doorbell"
                            selectedShape = "circle.fill"
                            selectedColor = Color(hex: "E89D00")
                        }
                        
                        let workItem = DispatchWorkItem {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                selectedShape = "circle"
                                activeButton = nil
                            }
                        }
                        animationWorkItem = workItem
                        DispatchQueue.main.asyncAfter(deadline: .now() + 20, execute: workItem)
                    }
                    
                    // Pulsante 2
                    AnimationButton(buttonID: "Button 2",
                                    primaryIcon: "fork.knife",
                                    shapeIcon: "square.fill",
                                    color: Color(hex: "24709F"),
                                    isActive: activeButton == "Meal",
                                    anyButtonActive: activeButton != nil) {
                        if activeButton == "Meal" {
                            animationWorkItem?.cancel()
                            animationWorkItem = nil
                            withAnimation(.easeInOut(duration: 0.5)) {
                                selectedShape = "circle"
                                activeButton = nil
                            }
                            return
                        }
                        
                        homeManager.flashLights(button: "Button 2", colorHue: 240)
                        withAnimation(.easeInOut(duration: 0.5)) {
                            activeButton = "Meal"
                            selectedShape = "square.fill"
                            selectedColor = Color(hex: "24709F")
                        }
                        
                        let workItem = DispatchWorkItem {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                selectedShape = "circle"
                                activeButton = nil
                            }
                        }
                        animationWorkItem = workItem
                        DispatchQueue.main.asyncAfter(deadline: .now() + 20, execute: workItem)
                    }
                    
                    // Pulsante 3
                    AnimationButton(buttonID: "Button 3",
                                    primaryIcon: "light.beacon.max.fill",
                                    shapeIcon: "triangle.fill",
                                    color: Color(hex: "B23837"),
                                    isActive: activeButton == "Alert",
                                    anyButtonActive: activeButton != nil) {
                        if activeButton == "Alert" {
                            animationWorkItem?.cancel()
                            animationWorkItem = nil
                            withAnimation(.easeInOut(duration: 0.5)) {
                                selectedShape = "circle"
                                activeButton = nil
                            }
                            return
                        }
                        
                        homeManager.flashLights(button: "Button 3", colorHue: 0)
                        withAnimation(.easeInOut(duration: 0.5)) {
                            activeButton = "Alert"
                            selectedShape = "triangle.fill"
                            selectedColor = Color(hex: "B23837")
                        }
                        
                        let workItem = DispatchWorkItem {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                selectedShape = "circle"
                                activeButton = nil
                            }
                        }
                        animationWorkItem = workItem
                        DispatchQueue.main.asyncAfter(deadline: .now() + 20, execute: workItem)
                    }
                    
                    // Pulsante 4
                    AnimationButton(buttonID: "Button 4",
                                    primaryIcon: "figure.walk",
                                    shapeIcon: "pentagon.fill",
                                    color: Color(hex: "237F52"),
                                    isActive: activeButton == "Approach",
                                    anyButtonActive: activeButton != nil) {
                        if activeButton == "Approach" {
                            animationWorkItem?.cancel()
                            animationWorkItem = nil
                            withAnimation(.easeInOut(duration: 0.5)) {
                                selectedShape = "circle"
                                activeButton = nil
                            }
                            return
                        }
                        
                        homeManager.flashLights(button: "Button 4", colorHue: 120)
                        withAnimation(.easeInOut(duration: 0.5)) {
                            activeButton = "Approach"
                            selectedShape = "pentagon.fill"
                            selectedColor = Color(hex: "237F52")
                        }
                        
                        let workItem = DispatchWorkItem {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                selectedShape = "circle"
                                activeButton = nil
                            }
                        }
                        animationWorkItem = workItem
                        DispatchQueue.main.asyncAfter(deadline: .now() + 20, execute: workItem)
                    }
                }
                .padding()
            }
            .padding(.top, 20)
            .sheet(isPresented: $isOnboardingShowing) {
                OnboardingView(isOnboardingShowing: $isOnboardingShowing)
            }
        }
    }
}



#Preview {
    ContentView()
}
