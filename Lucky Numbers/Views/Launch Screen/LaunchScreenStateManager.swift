//
//  LaunchScreenStateManager.swift
//  Lucky Numbers
//
//  Created by Matt Willie on 11/13/22.
//

import Foundation

enum LaunchScreenStep {
    case firstStep, secondStep, finished
}

@MainActor
final class LaunchScreenStateManager: ObservableObject {
    @Published private(set) var state: LaunchScreenStep = .firstStep
    
    func dismiss() {
        Task {
            state = .secondStep
            try? await Task.sleep(for: .seconds(1))
            self.state = .finished
        }
    }
}

