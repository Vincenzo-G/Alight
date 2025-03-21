//
//  ToggleButtonIntents.swift
//  Alight!
//
//  Created by Vincenzo Gerelli on 17/03/25.
//

import AppIntents
import SwiftUI




// Intent for Button 1 (Doorbell)
struct ToggleButton1Intent: AppIntent {
    static var title: LocalizedStringResource = "Toggle Doorbell"
    static var description = IntentDescription("Toggles the 'Doorbell' button in the app.")
    static var openAppWhenRun: Bool = true
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let homeManager = HomeManager.shared
        await MainActor.run {
            homeManager.flashLights(button: "Button 1", colorHue: 40)
        }
        
        // Post notification to trigger UI animation in ContentView
        NotificationCenter.default.post(name: .doorbellActivated, object: nil)
        
        return .result(dialog: "First button activated.")
    }
}


// Intent for Button 2 (Meal)
struct ToggleButton2Intent: AppIntent {
    static var title: LocalizedStringResource = "Toggle Meal"
    static var description = IntentDescription("Toggles the 'Meal' button in the app.")
    static var openAppWhenRun: Bool = true
    @AppStorage("activeButton") private var activeButton = ""
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let homeManager = HomeManager.shared
        
        await MainActor.run {
            withAnimation(.easeInOut(duration: 0.5)) {
                homeManager.flashLights(button: "Button 2", colorHue: 240)
                activeButton = "Meal"
            }
        }
        
        // Post notification to trigger UI animation in ContentView
        NotificationCenter.default.post(name: .mealActivated, object: nil)
        
        return .result(dialog: "Second button activated.")
    }
}

// Intent for Button 3 (Alert)
struct ToggleButton3Intent: AppIntent {
    static var title: LocalizedStringResource = "Toggle Alert"
    static var description = IntentDescription("Toggles the 'Alert' button in the app.")
    static var openAppWhenRun: Bool = true
    @AppStorage("activeButton") private var activeButton = ""
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let homeManager = HomeManager.shared
        
        await MainActor.run {
            withAnimation(.easeInOut(duration: 0.5)) {
                homeManager.flashLights(button: "Button 3", colorHue: 0)
                activeButton = "Alert"
            }
        }
        
        // Post notification to trigger UI animation in ContentView
        NotificationCenter.default.post(name: .alertActivated, object: nil)
        
        return .result(dialog: "Third button activated.")
    }
}

// Intent for Button 4 (Approach)
struct ToggleButton4Intent: AppIntent {
    static var title: LocalizedStringResource = "Toggle Approach"
    static var description = IntentDescription("Toggles the 'Approach' button in the app.")
    static var openAppWhenRun: Bool = true
    @AppStorage("activeButton") private var activeButton = ""
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let homeManager = HomeManager.shared
        
        await MainActor.run {
            withAnimation(.easeInOut(duration: 0.5)) {
                homeManager.flashLights(button: "Button 4", colorHue: 120)
                activeButton = "Approach"
            }
        }
        
        // Post notification to trigger UI animation in ContentView
        NotificationCenter.default.post(name: .approachActivated, object: nil)
        
        return .result(dialog: "Fourth button activated.")
    }
}
