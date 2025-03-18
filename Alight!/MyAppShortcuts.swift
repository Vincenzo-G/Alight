//
//  MyAppShortcuts.swift
//  Alight!
//
//  Created by Vincenzo Gerelli on 17/03/25.
//

import AppIntents

struct MyAppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        return [
            // Shortcut for Button 1
            AppShortcut(
                intent: ToggleButton1Intent(),
                phrases: [
                    "Ring the doorbell in \(.applicationName)"
                    
                    
                ],
                shortTitle: "Doorbell",
                systemImageName: "bell.fill"
            ),
            
            // Shortcut for Button 2
            AppShortcut(
                intent: ToggleButton2Intent(),
                phrases: [
                    "Time to eat with \(.applicationName)"
                ],
                shortTitle: "Meal",
                systemImageName: "fork.knife"
            ),
            
            // Shortcut for Button 3
            AppShortcut(
                intent: ToggleButton3Intent(),
                phrases: [
             
                    "Activate alert in \(.applicationName)"
                    
                ],
                shortTitle: "Alert",
                systemImageName: "light.beacon.max.fill"
            ),
            
            // Shortcut for Button 4
            AppShortcut(
                intent: ToggleButton4Intent(),
                phrases: [
                   
                    "Someone is approaching in \(.applicationName)"
                  
                ],
                shortTitle: "Approach",
                systemImageName: "figure.walk"
            )
        ]
    }
}
