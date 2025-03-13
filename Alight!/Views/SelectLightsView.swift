import SwiftUI
import HomeKit

struct SelectLightsView: View {
    @ObservedObject private var homeManager = HomeManager()
    let button: String // Determines which button's lights are being selected
    
    var allLightsSelected: Bool {
        let allLightIDs = homeManager.homes
            .flatMap { $0.accessories }
            .filter { $0.services.contains { $0.serviceType == HMServiceTypeLightbulb } }
            .map { $0.uniqueIdentifier }
        
        return Set(allLightIDs).isSubset(of: homeManager.selectedLights[button] ?? [])
    }
    
    var body: some View {
        List {
            // Toggle to select/deselect all lights for this specific button
            Toggle(isOn: Binding(
                get: { allLightsSelected },
                set: { newValue in toggleAllLights(selectAll: newValue) }
            )) {
                Text("Select all")
            }
            
            ForEach(homeManager.homes, id: \.uniqueIdentifier) { home in
                Section(header: Text(home.name)) {
                    ForEach(home.accessories.filter { $0.services.contains { $0.serviceType == HMServiceTypeLightbulb } }, id: \.uniqueIdentifier) { light in
                        HStack {
                            Text(light.name)
                            Spacer()
                            Toggle("", isOn: Binding(
                                get: { homeManager.selectedLights[button]?.contains(light.uniqueIdentifier) ?? false },
                                set: { _ in homeManager.toggleLightSelection(for: light, button: button) }
                            ))
                            .labelsHidden()
                        }
                    }
                }
            }
        }
        .navigationTitle("Select lights")
    }
    
    func toggleAllLights(selectAll: Bool) {
        let allLights = homeManager.homes
            .flatMap { $0.accessories }
            .filter { $0.services.contains { $0.serviceType == HMServiceTypeLightbulb } }
        
        for light in allLights {
            if selectAll {
                if !(homeManager.selectedLights[button]?.contains(light.uniqueIdentifier) ?? false) {
                    homeManager.toggleLightSelection(for: light, button: button)
                }
            } else {
                if homeManager.selectedLights[button]?.contains(light.uniqueIdentifier) ?? false {
                    homeManager.toggleLightSelection(for: light, button: button)
                }
            }
        }
    }

    
}

#Preview {
    SelectLightsView(button: "Button 1") // Example preview for Button 1 selection
}
