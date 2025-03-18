//
//  AnimationButton.swift
//  Alight!
//
//  Created by Gennaro Liguori on 19/03/25.
//

import SwiftUI

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
    let countdownProgress: Binding<Double>?

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
                    .fill(.thinMaterial)
                
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
