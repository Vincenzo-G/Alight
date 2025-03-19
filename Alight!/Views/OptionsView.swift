import SwiftUI

struct OptionsView: View {
    let buttonID: String
    @AppStorage("isOnboardingShowing") private var isOnboardingShowing = false
    @Environment(\.dismiss) private var dismiss

    @State private var buttonName: String
    @State private var iconName: String

    // Valori di default per il nome e l'icona di ogni bottone
    private let defaultNames: [String: String] = [
        "Button 1": "Doorbell",
        "Button 2": "Meal",
        "Button 3": "Alert",
        "Button 4": "Approach"
    ]
    
    private let defaultIcons: [String: String] = [
        "Button 1": "bell.fill",
        "Button 2": "fork.knife",
        "Button 3": "exclamationmark.triangle.fill",
        "Button 4": "figure.walk"
    ]
    
    // Lista delle icone disponibili per il Picker
    private let availableIcons: [String] = [
        "bell.fill",
        "fork.knife",
        "exclamationmark.triangle.fill",
        "figure.walk",
        "house.fill",
        "door.right.hand.closed",
        "tshirt.fill",
        "cloud.rain.fill",
        "alarm.fill",
        "number",
        "button.roundedbottom.horizontal.fill"
        
        
    ]
    
    init(buttonID: String) {
        self.buttonID = buttonID
        _buttonName = State(initialValue:
            UserDefaults.standard.string(forKey: "buttonName_\(buttonID)")
            ?? defaultNames[buttonID]
            ?? buttonID)
        _iconName = State(initialValue:
            UserDefaults.standard.string(forKey: "buttonIcon_\(buttonID)")
            ?? defaultIcons[buttonID]
            ?? availableIcons.first!)
    }
    
    var body: some View {
        NavigationStack {
            List {
                                
                Section(header: Text("Icon")) {
                    Picker("Select Icon", selection: $iconName) {
                        ForEach(availableIcons, id: \.self) { icon in
                            Image(systemName: icon)
                                .tag(icon)
                        }
                    }
                    .onChange(of: iconName) { _ in
                        saveIconName()
                    }
                }
                
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
                    Button("Done") {
                        saveButtonName()
                        saveIconName()
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func saveButtonName() {
        UserDefaults.standard.set(buttonName, forKey: "buttonName_\(buttonID)")
    }
    
    private func saveIconName() {
        UserDefaults.standard.set(iconName, forKey: "buttonIcon_\(buttonID)")
    }
}

#Preview {
    OptionsView(buttonID: "Button 1")
}
