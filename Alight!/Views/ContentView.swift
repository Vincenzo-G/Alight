//
//  ContentView.swift
//  Alight!
//
//  Created by Vincenzo Gerelli on 12/03/25.
//

//
//  ContentView.swift
//  Alight!
//
//  Created by Vincenzo Gerelli on 12/03/25.
//

import SwiftUI

// MARK: - Estensione per creare un Color da una stringa esadecimale
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

// MARK: - ProgressBarOverlay
struct ProgressBarOverlay: View {
    @Binding var progress: Double  // 1.0 = barra piena, 0.0 = vuota
    let activeColor: Color

    var body: some View {
        GeometryReader { geometry in
            Rectangle()
                .fill(activeColor)
                .frame(width: geometry.size.width * progress)
                .animation(.linear(duration: 20), value: progress)
                .frame(maxHeight: .infinity, alignment: .leading)
        }
        .clipped()
    }
}

// MARK: - Altre View (invariate)
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

// MARK: - AnimationButton
struct AnimationButton: View {
    @Environment(\.colorScheme) var colorScheme
    
    let buttonID: String
    let primaryIcon: String
    let shapeIcon: String
    let color: Color
    let isActive: Bool
    let anyButtonActive: Bool
    let action: () -> Void
    let countdownProgress: Binding<Double>?  // Binding per il progresso della barra

    @State private var isOptionsShowing = false
    @State private var buttonName: String

    private let defaultNames: [String: String] = [
        "Button 1": "Doorbell",
        "Button 2": "Meal",
        "Button 3": "Alert",
        "Button 4": "Approach"
    ]
    
    init(buttonID: String,
         primaryIcon: String,
         shapeIcon: String,
         color: Color,
         isActive: Bool,
         anyButtonActive: Bool,
         countdownProgress: Binding<Double>? = nil,
         action: @escaping () -> Void) {
        self.buttonID = buttonID
        self.primaryIcon = primaryIcon
        self.shapeIcon = shapeIcon
        self.color = color
        self.isActive = isActive
        self.anyButtonActive = anyButtonActive
        self.action = action
        self.countdownProgress = countdownProgress
        
        let storedName = UserDefaults.standard.string(forKey: "buttonName_\(buttonID)")
            ?? defaultNames[buttonID]
            ?? buttonID
        _buttonName = State(initialValue: storedName)
    }
    
    var dynamicTextColor: Color {
        if anyButtonActive && !isActive {
            return .gray
        } else {
            return colorScheme == .light ? .black : .white
        }
    }
    
    var dynamicShapeIconColor: Color {
        if anyButtonActive && !isActive {
            return .gray
        } else {
            return isActive ? (colorScheme == .light ? .black : .white) : color
        }
    }
    
    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.ultraThinMaterial)
                
                if isActive, let countdownProgress = countdownProgress {
                    ProgressBarOverlay(progress: countdownProgress, activeColor: color)
                }
                
                VStack {
                    HStack {
                        Image(systemName: primaryIcon)
                            .font(.largeTitle)
                            .foregroundColor(dynamicTextColor)
                        Spacer()
                        Button(action: { isOptionsShowing = true }) {
                            Image(systemName: "ellipsis")
                                .font(.title2)
                                .foregroundColor(dynamicTextColor.opacity(0.7))
                        }
                    }
                    .padding(.top, 10)
                    
                    Spacer()
                    
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
            }
            .frame(maxWidth: .infinity, minHeight: 150)
            .cornerRadius(20)
        }
        .sheet(isPresented: $isOptionsShowing, onDismiss: {
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

// MARK: - ContentView
struct ContentView: View {
    
    @StateObject private var homeManager = HomeManager.shared
    @AppStorage("isOnboardingShowing") private var isOnboardingShowing = true
    
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedShape: String = "circle"
    @State private var selectedColor: Color = .white
    @AppStorage("activeButton") var activeButton: String = ""
    
    // Variabile globale per gestire il timer visivo attivo
    @State private var animationWorkItem: DispatchWorkItem? = nil
    // Variabile globale per la progress bar condivisa
    @State private var progress: Double = 1.0
  

    // Funzione per resettare il timer e la progress bar, chiamata ad ogni pressione di qualsiasi tasto
    private func resetAllTimers() {
        animationWorkItem?.cancel()
        animationWorkItem = nil
        progress = 1.0
    }

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
                    
                    // Button 1 - Doorbell
                    AnimationButton(
                        buttonID: "Button 1",
                        primaryIcon: "bell.fill",
                        shapeIcon: "circle.fill",
                        color: Color(hex: "E89D00"),
                        isActive: activeButton == "Doorbell",
                        anyButtonActive: activeButton != "",
                        countdownProgress: activeButton == "Doorbell" ? $progress : nil
                    ) {
                        // Resetta tutti i timer e imposta il progress a 1.0 senza animazione
                        resetAllTimers()
                        
                        if activeButton == "Doorbell" {
                
                            homeManager.isCancelled = true
                            let lightsToTurnOff = homeManager.lights.filter {
                                homeManager.selectedLights["Button 1"]?.contains($0.uniqueIdentifier) ?? false
                            }
                            for light in lightsToTurnOff {
                                homeManager.turnOff(light)
                            }
                            withAnimation(.easeInOut(duration: 0.5)) {
                                selectedShape = "circle"
                                
                                
                            }
                            // Reset istantaneo del progress
                            withAnimation(nil) { progress = 1.0 }
                            return
                        }
                        
                        homeManager.isCancelled = false
                        homeManager.flashLights(button: "Button 1", colorHue: 40)
                        withAnimation(.easeInOut(duration: 0.5)) {
                            activeButton = "Doorbell"
                            selectedShape = "circle.fill"
                            selectedColor = Color(hex: "E89D00")
                        }
                        withAnimation(.linear(duration: 20)) {
                            progress = 0.0
                        }
                        
                        var workItem: DispatchWorkItem?
                        workItem = DispatchWorkItem {
                            if workItem?.isCancelled ?? false { return }
                            withAnimation(.easeInOut(duration: 0.5)) {
                                selectedShape = "circle"
                                activeButton = ""
                            }
                            withAnimation(nil) { progress = 1.0 }
                        }
                        if let workItem = workItem {
                            animationWorkItem = workItem
                            DispatchQueue.main.asyncAfter(deadline: .now() + 20, execute: workItem)
                        }
                    }
                    
                    // Button 2 - Meal
                    AnimationButton(
                        buttonID: "Button 2",
                        primaryIcon: "fork.knife",
                        shapeIcon: "square.fill",
                        color: Color(hex: "24709F"),
                        isActive: activeButton == "Meal",
                        anyButtonActive: activeButton != "",
                        countdownProgress: activeButton == "Meal" ? $progress : nil
                    ) {
                        resetAllTimers()
                        
                        if activeButton == "Meal" {
                            homeManager.isCancelled = true
                            let lightsToTurnOff = homeManager.lights.filter {
                                homeManager.selectedLights["Button 2"]?.contains($0.uniqueIdentifier) ?? false
                            }
                            for light in lightsToTurnOff {
                                homeManager.turnOff(light)
                            }
                            withAnimation(.easeInOut(duration: 0.5)) {
                                selectedShape = "circle"
                                activeButton = ""
                            }
                            withAnimation(nil) { progress = 1.0 }
                            return
                        }
                        
                        homeManager.isCancelled = false
                        homeManager.flashLights(button: "Button 2", colorHue: 240)
                        withAnimation(.easeInOut(duration: 0.5)) {
                            activeButton = "Meal"
                            selectedShape = "square.fill"
                            selectedColor = Color(hex: "24709F")
                        }
                        withAnimation(.linear(duration: 20)) {
                            progress = 0.0
                        }
                        
                        var workItem: DispatchWorkItem?
                        workItem = DispatchWorkItem {
                            if workItem?.isCancelled ?? false { return }
                            withAnimation(.easeInOut(duration: 0.5)) {
                                selectedShape = "circle"
                                activeButton = ""
                            }
                            withAnimation(nil) { progress = 1.0 }
                        }
                        if let workItem = workItem {
                            animationWorkItem = workItem
                            DispatchQueue.main.asyncAfter(deadline: .now() + 20, execute: workItem)
                        }
                    }
                    
                    // Button 3 - Alert
                    AnimationButton(
                        buttonID: "Button 3",
                        primaryIcon: "light.beacon.max.fill",
                        shapeIcon: "triangle.fill",
                        color: Color(hex: "B23837"),
                        isActive: activeButton == "Alert",
                        anyButtonActive: activeButton != "",
                        countdownProgress: activeButton == "Alert" ? $progress : nil
                    ) {
                        resetAllTimers()
                        
                        if activeButton == "Alert" {
                            homeManager.isCancelled = true
                            let lightsToTurnOff = homeManager.lights.filter {
                                homeManager.selectedLights["Button 3"]?.contains($0.uniqueIdentifier) ?? false
                            }
                            for light in lightsToTurnOff {
                                homeManager.turnOff(light)
                            }
                            withAnimation(.easeInOut(duration: 0.5)) {
                                selectedShape = "circle"
                                activeButton = ""
                            }
                            withAnimation(nil) { progress = 1.0 }
                            return
                        }
                        
                        homeManager.isCancelled = false
                        homeManager.flashLights(button: "Button 3", colorHue: 0)
                        withAnimation(.easeInOut(duration: 0.5)) {
                            activeButton = "Alert"
                            selectedShape = "triangle.fill"
                            selectedColor = Color(hex: "B23837")
                        }
                        withAnimation(.linear(duration: 20)) {
                            progress = 0.0
                        }
                        
                        var workItem: DispatchWorkItem?
                        workItem = DispatchWorkItem {
                            if workItem?.isCancelled ?? false { return }
                            withAnimation(.easeInOut(duration: 0.5)) {
                                selectedShape = "circle"
                                activeButton = ""
                            }
                            withAnimation(nil) { progress = 1.0 }
                        }
                        if let workItem = workItem {
                            animationWorkItem = workItem
                            DispatchQueue.main.asyncAfter(deadline: .now() + 20, execute: workItem)
                        }
                    }
                    
                    // Button 4 - Approach
                    AnimationButton(
                        buttonID: "Button 4",
                        primaryIcon: "figure.walk",
                        shapeIcon: "pentagon.fill",
                        color: Color(hex: "237F52"),
                        isActive: activeButton == "Approach",
                        anyButtonActive: activeButton != "",
                        countdownProgress: activeButton == "Approach" ? $progress : nil
                    ) {
                        resetAllTimers()
                        
                        if activeButton == "Approach" {
                            homeManager.isCancelled = true
                            let lightsToTurnOff = homeManager.lights.filter {
                                homeManager.selectedLights["Button 4"]?.contains($0.uniqueIdentifier) ?? false
                            }
                            for light in lightsToTurnOff {
                                homeManager.turnOff(light)
                            }
                            withAnimation(.easeInOut(duration: 0.5)) {
                                selectedShape = "circle"
                                activeButton = ""
                            }
                            withAnimation(nil) { progress = 1.0 }
                            return
                        }
                        
                        homeManager.isCancelled = false
                        homeManager.flashLights(button: "Button 4", colorHue: 120)
                        withAnimation(.easeInOut(duration: 0.5)) {
                            activeButton = "Approach"
                            selectedShape = "pentagon.fill"
                            selectedColor = Color(hex: "237F52")
                        }
                        withAnimation(.linear(duration: 20)) {
                            progress = 0.0
                        }
                        
                        var workItem: DispatchWorkItem?
                        workItem = DispatchWorkItem {
                            if workItem?.isCancelled ?? false { return }
                            withAnimation(.easeInOut(duration: 0.5)) {
                                selectedShape = "circle"
                                activeButton = ""
                            }
                            withAnimation(nil) { progress = 1.0 }
                        }
                        if let workItem = workItem {
                            animationWorkItem = workItem
                            DispatchQueue.main.asyncAfter(deadline: .now() + 20, execute: workItem)
                        }
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

// MARK: - Anteprima
#Preview {
    ContentView()
}
