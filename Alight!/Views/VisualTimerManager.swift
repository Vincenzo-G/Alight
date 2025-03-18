//
//  VisualTimerManager.swift
//  Alight!
//
//  Created by Gennaro Liguori on 19/03/25.
//

import SwiftUI


final class VisualTimerManager: ObservableObject {
    @Published var progress: Double = 1.0
    private var timer: Timer?
    private var startTime: Date?
    private var duration: TimeInterval = 20

    /// Avvia il timer per la durata specificata e chiama onComplete al termine.
    func start(duration: TimeInterval = 20, onComplete: @escaping () -> Void) {
        timer?.invalidate()  // Annulla eventuali timer in corso
        progress = 1.0
        self.duration = duration
        startTime = Date()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] timer in
            guard let self = self, let startTime = self.startTime else { return }
            let elapsed = Date().timeIntervalSince(startTime)
            self.progress = max(1.0 - (elapsed / self.duration), 0)
            if elapsed >= self.duration {
                timer.invalidate()
                onComplete()
            }
        }
    }
    
    /// Annulla il timer e resetta il progresso.
    func cancel() {
        timer?.invalidate()
        progress = 1.0
    }
}
