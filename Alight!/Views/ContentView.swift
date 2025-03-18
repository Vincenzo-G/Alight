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

/// Questa view disegna un rettangolo che, partendo da una larghezza pari a 100% (progress = 1.0),
/// si riduce da destra verso sinistra fino a 0% in 20 secondi.
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

// Vista per la forma centrale
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
                // Vista idle: applica il bounce solo al passaggio da una forma diversa
                Circle()
                    .stroke(Color(hex: "BDBDBD"), lineWidth: 15)
                    .frame(width: 330, height: 330)
                    .scaleEffect(idleBounce ? 1.05 : 1.0)
                    .onAppear {
                        // Se la vista idle è apparsa dopo una forma diversa, esegui il bounce
                        if lastShape != "circle" {
                            withAnimation(Animation.interpolatingSpring(stiffness: 100, damping: 10)) {
                                idleBounce = true
                            }
                            // Dopo un breve intervallo, torna alla scala normale
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                withAnimation(Animation.interpolatingSpring(stiffness: 100, damping: 10)) {
                                    idleBounce = false
                                }
                            }
                        }
                        lastShape = "circle"
                    }
            } else {
                // Vista per le altre forme: animazione di pulsazione continua
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
                        // Avvia la pulsazione continua
                        pulse = false
                        withAnimation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                            pulse = true
                        }
                        lastShape = shapeSymbol
                    }
            }
        }
        // La transizione spring viene applicata al cambio di view
        .transition(.scale)
        .id(shapeSymbol) // Forza SwiftUI a considerare il cambio di view come nuovo elemento
        .animation(.interpolatingSpring(stiffness: 40, damping: 100), value: shapeSymbol)
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

// MARK: - AnimationButton

/// Questo componente rappresenta un pulsante che, se attivo, mostra un overlay che "si svuota" come una barra
/// e in light mode gli elementi (icone e testo) vengono visualizzati in nero.
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
        
        // Controlla UserDefaults o usa il nome di default
        let storedName = UserDefaults.standard.string(forKey: "buttonName_\(buttonID)")
            ?? defaultNames[buttonID]
            ?? buttonID
        _buttonName = State(initialValue: storedName)
    }
    
    // Sfondo idle: in light mode è bianco, in dark mode systemGray4
    var idleBackground: Color {
        colorScheme == .light ? Color(hex: "FFFFFF") : Color(UIColor.systemGray4)
    }
    
    /// Se il pulsante è attivo in light mode, il colore di testo e delle icone diventa nero (in dark mode resta bianco);
    /// se inattivo, si usano i colori standard.
    var dynamicTextColor: Color {
        if anyButtonActive && !isActive {
            return .gray
        } else {
            if isActive {
                return colorScheme == .light ? .black : .white
            } else {
                return colorScheme == .light ? .black : .white
            }
        }
    }
    
    /// Per l'icona della forma in basso a destra: se il pulsante è attivo, in light mode diventa nero, altrimenti si usa il colore originale.
    var dynamicShapeIconColor: Color {
        if anyButtonActive && !isActive {
            return .gray
        } else {
            if isActive {
                return colorScheme == .light ? .black : .white
            } else {
                return color
            }
        }
    }
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // Sfondo idle
                idleBackground
                
                // Se il pulsante è attivo, aggiungiamo l'overlay che "si svuota"
                if isActive, let countdownProgress = countdownProgress {
                    ProgressBarOverlay(progress: countdownProgress, activeColor: color)
                }
                
                // Contenuto del pulsante
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
                        .disabled(anyButtonActive && !isActive)
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
        .disabled(anyButtonActive && !isActive)
        .sheet(isPresented: $isOptionsShowing, onDismiss: {

            // Refresh button name after closing OptionsView
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
    @State private var animationWorkItem: DispatchWorkItem? = nil  // Variabile per gestire il blocco programmato
    
    //@AppStorage("isButton1Triggered") private var isButton1Triggered = false
    
    @State private var progress: Double = 1.0  // Barra piena (1.0 = piena, 0.0 = vuota)

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color(colorScheme == .light ? Color(hex: "E5E5EA") : Color(hex: "1C1C1E"))
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                // La vista centrale (la forma) rimane invariata
                PulsingShapeView(shapeSymbol: selectedShape, color: selectedColor)
                    .frame(width: 300, height: 300)
                
                Spacer()
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    
                    // Button 1
                    AnimationButton(
                        buttonID: "Button 1",
                        primaryIcon: "bell.fill",
                        shapeIcon: "circle.fill",
                        color: Color(hex: "E89D00"),
                        isActive: activeButton == "Doorbell",
                        anyButtonActive: activeButton != "",
                        countdownProgress: activeButton == "Doorbell" ? $progress : nil
                    ) {
                        // Se il pulsante è già attivo, annulla l’animazione, resetta l’UI
                        // e spegni le luci selezionate per questo pulsante.
                        if activeButton == "Doorbell" {
                            // Se il pulsante attivo viene ripremuto, annulla il blocco programmato e torna in stato idle
                            animationWorkItem?.cancel()
                            animationWorkItem = nil
                            
                            // Imposta isCancelled a true per interrompere il flashing delle luci
                            homeManager.isCancelled = true

                            // Recupera le luci selezionate per Button 1 e chiama turnOff su ciascuna
                            let lightsToTurnOff = homeManager.lights.filter {
                                homeManager.selectedLights["Button 1"]?.contains($0.uniqueIdentifier) ?? false
                            }
                            for light in lightsToTurnOff {
                                homeManager.turnOff(light)
                            }
                            
                            withAnimation(.easeInOut(duration: 0.5)) {
                                selectedShape = "circle"
                                activeButton = ""
                            }
                            progress = 1.0
                            return
                        }
                        
                        // Se il pulsante non è attivo, avvia il flashing delle luci e l’animazione
                        // Assicurati di resettare isCancelled a false prima di avviare una nuova animazione
                        homeManager.isCancelled = false
                        homeManager.flashLights(button: "Button 1", colorHue: 40)
                        withAnimation(.easeInOut(duration: 0.5)) {
                            activeButton = "Doorbell"
                            selectedShape = "circle.fill"
                            selectedColor = Color(hex: "E89D00")
                        }
                        
                        progress = 1.0
                        withAnimation(.linear(duration: 20)) {
                            progress = 0.0
                        }
                        
                        let workItem = DispatchWorkItem {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                selectedShape = "circle"
                                activeButton = ""
                            }
                            progress = 1.0
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
                                    anyButtonActive: activeButton != "",
                                    countdownProgress: activeButton == "Meal" ? $progress : nil) {
                        if activeButton == "Meal" {
                            animationWorkItem?.cancel()
                            animationWorkItem = nil
                            
                            // Imposta il flag di cancellazione per interrompere il flashing
                            homeManager.isCancelled = true
                            
                            // Recupera le luci selezionate per Button 2 e spegnile
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
                            progress = 1.0
                            return
                        }
                        
                        // Resetta il flag prima di avviare una nuova animazione
                        homeManager.isCancelled = false
                        homeManager.flashLights(button: "Button 2", colorHue: 240)
                        withAnimation(.easeInOut(duration: 0.5)) {
                            activeButton = "Meal"
                            selectedShape = "square.fill"
                            selectedColor = Color(hex: "24709F")
                        }
                        
                        progress = 1.0
                        withAnimation(.linear(duration: 20)) {
                            progress = 0.0
                        }
                        
                        let workItem = DispatchWorkItem {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                selectedShape = "circle"
                                activeButton = ""
                            }
                            progress = 1.0
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
                                    anyButtonActive: activeButton != "",
                                    countdownProgress: activeButton == "Alert" ? $progress : nil) {
                        if activeButton == "Alert" {
                            animationWorkItem?.cancel()
                            animationWorkItem = nil
                            
                            // Imposta il flag di cancellazione per interrompere il flashing
                            homeManager.isCancelled = true
                            
                            // Recupera le luci selezionate per Button 3 e spegnile
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
                            progress = 1.0
                            return
                        }
                        
                        // Resetta il flag prima di avviare una nuova animazione
                        homeManager.isCancelled = false
                        homeManager.flashLights(button: "Button 3", colorHue: 0)
                        withAnimation(.easeInOut(duration: 0.5)) {
                            activeButton = "Alert"
                            selectedShape = "triangle.fill"
                            selectedColor = Color(hex: "B23837")
                        }
                        
                        progress = 1.0
                        withAnimation(.linear(duration: 20)) {
                            progress = 0.0
                        }
                        
                        let workItem = DispatchWorkItem {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                selectedShape = "circle"
                                activeButton = ""
                            }
                            progress = 1.0
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
                                    anyButtonActive: activeButton != "",
                                    countdownProgress: activeButton == "Approach" ? $progress : nil) {
                        if activeButton == "Approach" {
                            animationWorkItem?.cancel()
                            animationWorkItem = nil
                            
                            // Imposta il flag di cancellazione per interrompere il flashing
                            homeManager.isCancelled = true
                            
                            // Recupera le luci selezionate per Button 4 e spegnile
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
                            progress = 1.0
                            return
                        }
                        
                        // Resetta il flag prima di avviare una nuova animazione
                        homeManager.isCancelled = false
                        homeManager.flashLights(button: "Button 4", colorHue: 120)
                        withAnimation(.easeInOut(duration: 0.5)) {
                            activeButton = "Approach"
                            selectedShape = "pentagon.fill"
                            selectedColor = Color(hex: "237F52")
                        }
                        
                        progress = 1.0
                        withAnimation(.linear(duration: 20)) {
                            progress = 0.0
                        }
                        
                        let workItem = DispatchWorkItem {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                selectedShape = "circle"
                                activeButton = ""
                            }
                            progress = 1.0
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
