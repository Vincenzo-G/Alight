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

import SwiftUI

extension Notification.Name {
    static let doorbellActivated = Notification.Name("doorbellActivated")
    static let mealActivated = Notification.Name("mealActivated")
    static let alertActivated = Notification.Name("alertActivated")
    static let approachActivated = Notification.Name("approachActivated")
}

struct ContentView: View {
    
    @StateObject private var homeManager = HomeManager.shared
    @StateObject private var timerManager = VisualTimerManager()
    @AppStorage("isOnboardingShowing") private var isOnboardingShowing = true
    
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedShape: String = "circle"
    @State private var selectedColor: Color = .white
    @AppStorage("activeButton") var activeButton: String = ""
    
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
                        countdownProgress: activeButton == "Doorbell" ? $timerManager.progress : nil
                    ) {
                        timerManager.cancel()
                        
                        if activeButton == "Doorbell" {
                            homeManager.isCancelled = true
                            let lightsToTurnOff = homeManager.lights.filter {
                                homeManager.selectedLights["Button 1"]?.contains($0.uniqueIdentifier) ?? false
                            }
                            lightsToTurnOff.forEach { homeManager.turnOff($0) }
                            withAnimation(.easeInOut(duration: 0.5)) {
                                selectedShape = "circle"
                                activeButton = ""
                            }
                            return
                        }
                        
                        homeManager.isCancelled = false
                        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                        homeManager.flashLights(button: "Button 1", colorHue: 40)
                        withAnimation(.easeInOut(duration: 0.5)) {
                            activeButton = "Doorbell"
                            selectedShape = "circle.fill"
                            selectedColor = Color(hex: "E89D00")
                        }
                        timerManager.start(duration: 20) {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                selectedShape = "circle"
                                activeButton = ""
                            }
                        }
                    }
                    .accessibilityHint("Press to flash lights")
                    
                    // Button 2 - Meal
                    AnimationButton(
                        buttonID: "Button 2",
                        primaryIcon: "fork.knife",
                        shapeIcon: "square.fill",
                        color: Color(hex: "24709F"),
                        isActive: activeButton == "Meal",
                        anyButtonActive: activeButton != "",
                        countdownProgress: activeButton == "Meal" ? $timerManager.progress : nil
                    ) {
                        timerManager.cancel()
                        
                        if activeButton == "Meal" {
                            homeManager.isCancelled = true
                            let lightsToTurnOff = homeManager.lights.filter {
                                homeManager.selectedLights["Button 2"]?.contains($0.uniqueIdentifier) ?? false
                            }
                            lightsToTurnOff.forEach { homeManager.turnOff($0) }
                            withAnimation(.easeInOut(duration: 0.5)) {
                                selectedShape = "circle"
                                activeButton = ""
                            }
                            return
                        }
                        
                        homeManager.isCancelled = false
                        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                        homeManager.flashLights(button: "Button 2", colorHue: 240)
                        withAnimation(.easeInOut(duration: 0.5)) {
                            activeButton = "Meal"
                            selectedShape = "square.fill"
                            selectedColor = Color(hex: "24709F")
                        }
                        timerManager.start(duration: 20) {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                selectedShape = "circle"
                                activeButton = ""
                            }
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
                        countdownProgress: activeButton == "Alert" ? $timerManager.progress : nil
                    ) {
                        timerManager.cancel()
                        
                        if activeButton == "Alert" {
                            homeManager.isCancelled = true
                            let lightsToTurnOff = homeManager.lights.filter {
                                homeManager.selectedLights["Button 3"]?.contains($0.uniqueIdentifier) ?? false
                            }
                            lightsToTurnOff.forEach { homeManager.turnOff($0) }
                            withAnimation(.easeInOut(duration: 0.5)) {
                                selectedShape = "circle"
                                activeButton = ""
                            }
                            return
                        }
                        
                        homeManager.isCancelled = false
                        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                        homeManager.flashLights(button: "Button 3", colorHue: 0)
                        withAnimation(.easeInOut(duration: 0.5)) {
                            activeButton = "Alert"
                            selectedShape = "triangle.fill"
                            selectedColor = Color(hex: "B23837")
                        }
                        timerManager.start(duration: 20) {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                selectedShape = "circle"
                                activeButton = ""
                            }
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
                        countdownProgress: activeButton == "Approach" ? $timerManager.progress : nil
                    ) {
                        timerManager.cancel()
                        
                        if activeButton == "Approach" {
                            homeManager.isCancelled = true
                            let lightsToTurnOff = homeManager.lights.filter {
                                homeManager.selectedLights["Button 4"]?.contains($0.uniqueIdentifier) ?? false
                            }
                            lightsToTurnOff.forEach { homeManager.turnOff($0) }
                            withAnimation(.easeInOut(duration: 0.5)) {
                                selectedShape = "circle"
                                activeButton = ""
                            }
                            return
                        }
                        
                        homeManager.isCancelled = false
                        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                        homeManager.flashLights(button: "Button 4", colorHue: 120)
                        withAnimation(.easeInOut(duration: 0.5)) {
                            activeButton = "Approach"
                            selectedShape = "pentagon.fill"
                            selectedColor = Color(hex: "237F52")
                        }
                        timerManager.start(duration: 20) {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                selectedShape = "circle"
                                activeButton = ""
                            }
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
        // Listener per la notifica Doorbell (Button 1)
        .onReceive(NotificationCenter.default.publisher(for: .doorbellActivated)) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                activeButton = "Doorbell"
                selectedShape = "circle.fill"
                selectedColor = Color(hex: "E89D00")
            }
            timerManager.start(duration: 20) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    selectedShape = "circle"
                    activeButton = ""
                }
            }
        }
        // Listener per la notifica Meal (Button 2)
        .onReceive(NotificationCenter.default.publisher(for: .mealActivated)) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                activeButton = "Meal"
                selectedShape = "square.fill"
                selectedColor = Color(hex: "24709F")
            }
            timerManager.start(duration: 20) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    selectedShape = "circle"
                    activeButton = ""
                }
            }
        }
        // Listener per la notifica Alert (Button 3)
        .onReceive(NotificationCenter.default.publisher(for: .alertActivated)) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                activeButton = "Alert"
                selectedShape = "triangle.fill"
                selectedColor = Color(hex: "B23837")
            }
            timerManager.start(duration: 20) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    selectedShape = "circle"
                    activeButton = ""
                }
            }
        }
        // Listener per la notifica Approach (Button 4)
        .onReceive(NotificationCenter.default.publisher(for: .approachActivated)) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                activeButton = "Approach"
                selectedShape = "pentagon.fill"
                selectedColor = Color(hex: "237F52")
            }
            timerManager.start(duration: 20) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    selectedShape = "circle"
                    activeButton = ""
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
