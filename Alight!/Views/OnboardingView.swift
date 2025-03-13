//
//  OnboardingView.swift
//  Alight!
//
//  Created by Vincenzo Gerelli on 07/03/25.
//


import SwiftUI

struct OnboardingView: View {
    
    @Binding var isOnboardingShowing: Bool
    @State private var currentIndex: Int = 0  // ✅ Track the current page index
    @FocusState private var isKeyboardVisible: Bool  // ✅ Track keyboard visibility
    
    var body: some View {
        VStack {
            TabView(selection: $currentIndex) {  // ✅ Track current index
                OnboardingPageView(systemImageName: "globe", title: "Welcome", description: "Welcome to the app", color: .blue)
                    .tag(0)
                
                OnboardingPageView(systemImageName: "lightbulb.max", title: "Select the lights", description: "Select the lights for each button", color: .blue)
                    .tag(1)
                
                OnboardingPageView(systemImageName: "square", title: "Quadrato", description: "Queste sono le informazioni", color: .blue)
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: isKeyboardVisible ? .never : .always))  // ✅ Hide when keyboard appears
            .indexViewStyle(.page(backgroundDisplayMode: isKeyboardVisible ? .never : .always))
            .interactiveDismissDisabled(true)
            
            // ✅ "Continue" button visible but only enabled on the last page
            Button {
                if currentIndex == 2 {  // ✅ Only allow tap if on last page
                    isOnboardingShowing.toggle()
                }
            } label: {
                Text("CONTINUE")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            }
            .buttonStyle(.borderedProminent)
            .padding()
            .disabled(currentIndex < 2)  // ✅ Disabled unless on last page
            .opacity(currentIndex < 2 ? 0.5 : 1.0)  // ✅ Greyed out if disabled
        }
    }
}

struct OnboardingPageView: View {
    let systemImageName: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: systemImageName)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(color)
            
            Text(title)
                .font(.largeTitle)
                .bold()
            
            Text(description)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

/*
struct OnboardingOptionsView: View {
    let buttonID: String
    @State private var buttonName: String = ""
    
    var body: some View {
        VStack {
            Text("Customize button \(buttonName)")
                .font(.title)
                .fontWeight(.bold)
                .padding()
            
            List {
                Section(header: Text("Name")) {
                    TextField("Enter button name", text: $buttonName, onCommit: saveButtonName)
                }
            }
            .frame(height: 90)

            Text("Select lights")
                .font(.title)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 30)
                        .padding(.bottom, 0)
            
            SelectLightsView(button: buttonID)
                
            }
            
    }
    
    private func saveButtonName() {
        UserDefaults.standard.set(buttonName, forKey: "buttonName_\(buttonID)")
    }
    
} */


#Preview {
    OnboardingView(isOnboardingShowing: .constant(true))
        .preferredColorScheme(.dark)
}
