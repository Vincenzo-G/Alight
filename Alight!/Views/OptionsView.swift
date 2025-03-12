import SwiftUI

struct OptionsView: View {
    @AppStorage("isOnboardingShowing") private var isOnboardingShowing = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Select lights")) {
                    NavigationLink("Button 1", destination: SelectLightsView(button: "Button 1"))
                    NavigationLink("Button 2", destination: SelectLightsView(button: "Button 2"))
                    NavigationLink("Button 3", destination: SelectLightsView(button: "Button 3"))
                    NavigationLink("Button 4", destination: SelectLightsView(button: "Button 4"))

                }
                
                Section(header: Text("Debug")) {
                    Toggle("Show OnboardingingView", isOn: $isOnboardingShowing)
                }
            }
            .navigationTitle("Options")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    OptionsView()
}
