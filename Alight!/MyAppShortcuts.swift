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
                    "Tap the first button in \(.applicationName)",
                    "Ring the doorbell in \(.applicationName)",
                    "Turn on the circle in \(.applicationName)"
                ],
                shortTitle: "Doorbell",
                systemImageName: "bell.fill"
            ),
            
            // Shortcut for Button 2
            AppShortcut(
                intent: ToggleButton2Intent(),
                phrases: [
                    "Tap the second button in \(.applicationName)",
                    "Time to eat with \(.applicationName)",
                    "Turn on the square in \(.applicationName)"
                ],
                shortTitle: "Meal",
                systemImageName: "fork.knife"
            ),
            
            // Shortcut for Button 3
            AppShortcut(
                intent: ToggleButton3Intent(),
                phrases: [
                    "Tap the third button in \(.applicationName)",
                    "Activate alert in \(.applicationName)",
                    "Turn on the triangle in \(.applicationName)"
                ],
                shortTitle: "Alert",
                systemImageName: "light.beacon.max.fill"
            ),
            
            // Shortcut for Button 4
            AppShortcut(
                intent: ToggleButton4Intent(),
                phrases: [
                    "Tap the fourth button in \(.applicationName)",
                    "Someone is approaching in \(.applicationName)",
                    "Turn on the pentagon in \(.applicationName)"
                ],
                shortTitle: "Approach",
                systemImageName: "figure.walk"
            )
        ]
    }
}
