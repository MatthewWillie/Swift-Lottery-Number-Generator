//
//  LaunchScreenStateManager.swift
//  Lucky Numbers
//
//  Created by Matt Willie on 11/13/22.
//

import Foundation

final class LaunchScreenStateManager: ObservableObject {    @MainActor
    @Published private(set) var state: LaunchScreenStep = .firstStep
    @MainActor
    func dismiss() {
        Task {
        state = .secondStep
        try? await Task.sleep(for: Duration.seconds(1))
        self.state = .finished
            
        }
    }
}
