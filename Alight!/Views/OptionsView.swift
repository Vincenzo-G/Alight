import SwiftUI

struct OptionsView: View {
    let buttonID: String  // Unique button identifier
    @AppStorage("isOnboardingShowing") private var isOnboardingShowing = false
    @Environment(\.dismiss) private var dismiss
    
    @State private var buttonName: String  // Local state for text field
    
    init(buttonID: String) {
        self.buttonID = buttonID
        // Load stored name or default to buttonID
        _buttonName = State(initialValue: UserDefaults.standard.string(forKey: "buttonName_\(buttonID)") ?? buttonID)
    }
    
    var body: some View {
            List {
                // **Edit Button Name**
                Section(header: Text("Name")) {
                    TextField("Enter button name", text: $buttonName, onCommit: saveButtonName)
                }
                
                // **Navigate to Select Lights**
                Section(header: Text("devices")) {
                    NavigationLink("Select lights", destination: SelectLightsView(button: buttonID))
                }
                
                // **Debug Section**
                Section(header: Text("Debug")) {
                    Toggle("Show OnboardingView", isOn: $isOnboardingShowing)
                }
            }
            .navigationTitle("Options")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        saveButtonName()
                        dismiss()
                    }
                }
        }
    }
    
    // **Persist Button Name**
    private func saveButtonName() {
        UserDefaults.standard.set(buttonName, forKey: "buttonName_\(buttonID)")
    }
}

#Preview {
    NavigationView(){
        OptionsView(buttonID: "Button 1")
    }
}
