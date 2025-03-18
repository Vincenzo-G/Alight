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
                    "Tap the first button",
                    "Ring the doorbell with Santa Claus",
                    "Turn on the circle"
                ],
                shortTitle: "Doorbell",
                systemImageName: "bell.fill"
            ),
            
            // Shortcut for Button 2
            AppShortcut(
                intent: ToggleButton2Intent(),
                phrases: [
                    "Tap the second button",
                    "Time to eat",
                    "Turn on the square"
                ],
                shortTitle: "Meal",
                systemImageName: "fork.knife"
            ),
            
            // Shortcut for Button 3
            AppShortcut(
                intent: ToggleButton3Intent(),
                phrases: [
                    "Scream the third button",
                    "Activate alert",
                    "Turn on the triangle"
                ],
                shortTitle: "Alert",
                systemImageName: "light.beacon.max.fill"
            ),
            
            // Shortcut for Button 4
            AppShortcut(
                intent: ToggleButton4Intent(),
                phrases: [
                    "Tap the fourth button",
                    "Someone is approaching",
                    "Turn on the pentagon"
                ],
                shortTitle: "Approach",
                systemImageName: "figure.walk"
            )
        ]
    }
}
