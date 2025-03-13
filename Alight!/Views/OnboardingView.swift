//
//  OnboardingView.swift
//  Alight!
//
//  Created by Vincenzo Gerelli on 07/03/25.
//


import SwiftUI

struct OnboardingView: View {
    
    @Binding var isOnboardingShowing: Bool
    
    var body: some View {
        TabView(){
            OnboardingPageView(systemImageName: "globe", title: "Welcome", description: "Welcome to the app", color: .blue)
            OnboardingPageView(systemImageName: "lightbulb.max", title: "Select the lights", description: "Select the lights for each button (you can modify them later if you desire to)", color: .blue)
            OnboardingOptionsView(button: "Button 1")
            OnboardingOptionsView(button: "Button 2")
            OnboardingOptionsView(button: "Button 3")
            OnboardingOptionsView(button: "Button 4")
            OnboardingPageView(systemImageName: "square", title: "Quadrato", description: "Queste sono le informazioni", color: .blue)
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .interactiveDismissDisabled(true)
        
        Button {
            isOnboardingShowing.toggle()
        } label: {
            Text("CONTINUE")
                .font(.headline)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
        
        }
        .buttonStyle(.borderedProminent)
        .padding()
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

struct OnboardingOptionsView: View {
    let button: String
    
    var body: some View {
        VStack {
            Text("Customize \(button)")
                .font(.title)
                .fontWeight(.bold)
                .padding()
            
            OptionsView(buttonID: button)
            
        }
    }
}


#Preview {
    OnboardingView(isOnboardingShowing: .constant(true))
        .preferredColorScheme(.dark)
}
