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
                    "Button 1 in \(.applicationName)"
                    
                    
                ],
                shortTitle: "Doorbell",
                systemImageName: "bell.fill"
            ),
            
            // Shortcut for Button 2
            AppShortcut(
                intent: ToggleButton2Intent(),
                phrases: [
                    "Button 2 in \(.applicationName)"
                ],
                shortTitle: "Meal",
                systemImageName: "fork.knife"
            ),
            
            // Shortcut for Button 3
            AppShortcut(
                intent: ToggleButton3Intent(),
                phrases: [
             
                    "Button 3 in \(.applicationName)"
                    
                ],
                shortTitle: "Alert",
                systemImageName: "light.beacon.max.fill"
            ),
            
            // Shortcut for Button 4
            AppShortcut(
                intent: ToggleButton4Intent(),
                phrases: [
                   
                    "Button 4 in \(.applicationName)"
                  
                ],
                shortTitle: "Approach",
                systemImageName: "figure.walk"
            )
        ]
    }
}
