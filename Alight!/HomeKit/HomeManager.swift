import Foundation
import HomeKit

class HomeManager: NSObject, ObservableObject, HMHomeManagerDelegate {
    @Published var currentAction: String = ""
    @Published var homes: [HMHome] = []
    @Published var lights: [HMAccessory] = []
    
    private var homeManager: HMHomeManager!

    @Published var selectedLights: [String: Set<UUID>] = [
            "Button 1": [],
            "Button 2": [],
            "Button 3": [],
            "Button 4": []
        ]

    private let selectedLightsKeyPrefix = "selectedLights_"

        override init() {
            super.init()
            homeManager = HMHomeManager()
            homeManager.delegate = self
            loadSelectedLights() // Load saved selections
        }

        func toggleLightSelection(for light: HMAccessory, button: String) {
            let lightID = light.uniqueIdentifier

            if selectedLights[button]?.contains(lightID) == true {
                selectedLights[button]?.remove(lightID)
            } else {
                selectedLights[button]?.insert(lightID)
            }

            saveSelectedLights(for: button) // Save after toggling
            objectWillChange.send()
        }

        // Save selected lights for a specific button to UserDefaults
        private func saveSelectedLights(for button: String) {
            let key = selectedLightsKeyPrefix + button
            let ids = selectedLights[button]?.map { $0.uuidString } ?? []
            UserDefaults.standard.set(ids, forKey: key)
        }

        // Load selected lights for all buttons from UserDefaults
        private func loadSelectedLights() {
            for button in ["Button 1", "Button 2", "Button 3", "Button 4"] {
                let key = selectedLightsKeyPrefix + button
                if let storedUUIDs = UserDefaults.standard.array(forKey: key) as? [String] {
                    selectedLights[button] = Set(storedUUIDs.compactMap { UUID(uuidString: $0) })
                }
            }
        }
    
    var accessibleLightsCount: Int {
        return lights.filter { $0.isReachable }.count
    }
    
    
    // Aggiorna le case quando i dati di HomeKit cambiano
    func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
        DispatchQueue.main.async {
            self.homes = manager.homes
            if let home = self.homes.first {
                self.findLights(in: home)
            }
        }
    }

    // Trova le luci smart nella casa
    func findLights(in home: HMHome) {
        self.lights = home.accessories.filter { accessory in
            accessory.services.contains { service in
                service.serviceType == HMServiceTypeLightbulb
            }
        }
    }

    // Funzione per accendere/spegnere una luce
    func toggleLight(_ light: HMAccessory) {
        guard let powerCharacteristic = light.services
                .flatMap({ $0.characteristics })
                .first(where: { $0.characteristicType == HMCharacteristicTypePowerState }) else {
            print("⚠️ Nessuna caratteristica di accensione trovata per \(light.name)")
            return
        }

        powerCharacteristic.readValue { error in
            if let error = error {
                print("Errore nella lettura dello stato: \(error.localizedDescription)")
                return
            }
            if let currentValue = powerCharacteristic.value as? Bool {
                let newValue = !currentValue
                powerCharacteristic.writeValue(newValue) { error in
                    if let error = error {
                        print("Errore nella scrittura dello stato: \(error.localizedDescription)")
                    } else {
                        print("✅ Luce \(light.name) impostata su \(newValue ? "Accesa" : "Spenta")")
                    }
                }
            }
        }
    }
    
    // Funzione per impostare il colore della luce tramite HMCharacteristicTypeHue
    func setHue(for light: HMAccessory, hue: Double) {
        guard let hueCharacteristic = light.services
            .flatMap({ $0.characteristics })
            .first(where: { $0.characteristicType == HMCharacteristicTypeHue }) else {
                print("⚠️ Caratteristica di colore (Hue) non trovata per \(light.name)")
                return
        }
        hueCharacteristic.writeValue(hue) { error in
            if let error = error {
                print("Errore nel cambio del colore per \(light.name): \(error.localizedDescription)")
            } else {
                print("✅ Colore impostato a \(hue) per \(light.name)")
            }
        }
    }
    
    // Funzione per impostare la luminosità tramite HMCharacteristicTypeBrightness
    func setBrightness(for light: HMAccessory, brightness: Double) {
        guard let brightnessCharacteristic = light.services
            .flatMap({ $0.characteristics })
            .first(where: { $0.characteristicType == HMCharacteristicTypeBrightness }) else {
                print("⚠️ Caratteristica di luminosità non trovata per \(light.name)")
                return
        }
        brightnessCharacteristic.writeValue(brightness) { error in
            if let error = error {
                print("Errore nel cambio della luminosità per \(light.name): \(error.localizedDescription)")
            } else {
                print("✅ Luminosità impostata a \(brightness) per \(light.name)")
            }
        }
    }

    // Funzione per impostare la saturazione tramite HMCharacteristicTypeSaturation
    func setSaturation(for light: HMAccessory, saturation: Double) {
        guard let saturationCharacteristic = light.services
            .flatMap({ $0.characteristics })
            .first(where: { $0.characteristicType == HMCharacteristicTypeSaturation }) else {
                print("⚠️ Caratteristica di saturazione non trovata per \(light.name)")
                return
        }
        saturationCharacteristic.writeValue(saturation) { error in
            if let error = error {
                print("Errore nel cambio della saturazione per \(light.name): \(error.localizedDescription)")
            } else {
                print("✅ Saturazione impostata a \(saturation) per \(light.name)")
            }
        }
    }
    
    // Funzione per far lampeggiare tutte le luci della casa
    func flashLights(button: String, cycles: Int, brightness: Double = 100, saturation: Double = 100, colorHue: Double) {
        currentAction = "Flashing lights for \(button)"
        
        // Load selected lights for the specific button
        loadSelectedLights()
        
        // Get the selected lights for this button
        let lightsToFlash = lights.filter { selectedLights[button]?.contains($0.uniqueIdentifier) ?? false }
        
        guard !lightsToFlash.isEmpty else {
            print("⚠️ No selected lights to flash for \(button)")
            return
        }

        for light in lightsToFlash {
            setHue(for: light, hue: colorHue)
            setBrightness(for: light, brightness: brightness)
            setSaturation(for: light, saturation: saturation)

            let totalToggles = cycles * 2
            var toggleCount = 0

            func performToggle() {
                guard toggleCount < totalToggles else {
                    print("✅ Flashing completed for \(light.name) in \(button)")
                    return
                }
                toggleLight(light)
                toggleCount += 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    performToggle()
                }
            }

            performToggle()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + (Double(cycles) * 2) + 2) {
            self.currentAction = "Idle"
        }
    }

    
    
}



