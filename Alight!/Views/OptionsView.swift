import SwiftUI

struct OptionsView: View {
    let buttonID: String
    @AppStorage("isOnboardingShowing") private var isOnboardingShowing = false
    @Environment(\.dismiss) private var dismiss
    
    @State private var buttonName: String
    
    private let defaultNames: [String: String] = [
        "Button 1": "Doorbell",
        "Button 2": "Meal",
        "Button 3": "Alert",
        "Button 4": "Approach"
    ]

    init(buttonID: String) {
        self.buttonID = buttonID
        _buttonName = State(initialValue: UserDefaults.standard.string(forKey: "buttonName_\(buttonID)")
                            ?? defaultNames[buttonID]
                            ?? buttonID)
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Name")) {
                    TextField("Enter button name", text: $buttonName, onCommit: saveButtonName)
                }
                
                Section(header: Text("Devices")) {
                    NavigationLink("Select lights", destination: SelectLightsView(button: buttonID))
                }
                
                Section(header: Text("Debug")) {
                    Toggle("Show OnboardingView", isOn: $isOnboardingShowing)
                }
            }
            .navigationTitle("Options")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveButtonName()
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func saveButtonName() {
        UserDefaults.standard.set(buttonName, forKey: "buttonName_\(buttonID)")
    }
}

#Preview {
        OptionsView(buttonID: "")
}
