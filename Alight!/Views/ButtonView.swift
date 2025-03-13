/*import SwiftUI

struct ButtonView: View {
    
    @StateObject private var homeManager = HomeManager()
    @AppStorage("isOnboardingShowing") private var isOnboardingShowing = true
    @State private var isOptionsShowing = false  // For opening the options menu
    
    func triggerHapticFeedback() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }
    
    func alertButton(title: String, color: Color, hue: Double) -> some View {
        Button(action: {
            print("Flashing lights for \(title)")
            triggerHapticFeedback()
            homeManager.flashLights(button: title, cycles: 3, colorHue: hue) // Now targets specific button
        }) {
            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: 30)
                    .fill(color.opacity(0.7))
                Text("\(title.uppercased()) CODE")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(30)
                    .foregroundColor(.white)
            }
        }
        .frame(height: 80)
    }

    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.black, Color.black]),
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
                .ignoresSafeArea()
                
                VStack(spacing: 50) {
                    
                    Text("Available lights: \(homeManager.accessibleLightsCount)")
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .padding(.top, 8)
                    
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(Color.white, lineWidth: 2)
                        .frame(maxWidth: .infinity)
                        .frame(height: 80)
                        .overlay(
                            Text(homeManager.currentAction.isEmpty ? "Idle" : homeManager.currentAction)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.leading)
                        )
                        .padding(.horizontal)
                    
                    // Buttons
                    alertButton(title: "Button 1", color: .green, hue: 120)
                        .padding(.horizontal)
                    
                    alertButton(title: "Button 2", color: .orange, hue: 30)
                        .padding(.horizontal)
                    
                    alertButton(title: "Button 3", color: .red, hue: 0)
                        .padding(.horizontal)
                    
                    alertButton(title: "Button 4", color: .blue, hue: 240)
                        .padding(.horizontal)
                    
                    Spacer() // Pushes content to the top
                }
            }
            .navigationTitle("Home")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isOptionsShowing = true
                    }) {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.white)
                    }
                }
            }
            .sheet(isPresented: $isOptionsShowing) {
                //OptionsView()
            }
            .sheet(isPresented: $isOnboardingShowing) {
                OnboardingView(isOnboardingShowing: $isOnboardingShowing)
            }
        }
    }
}

#Preview {
    ButtonView()
}*/
