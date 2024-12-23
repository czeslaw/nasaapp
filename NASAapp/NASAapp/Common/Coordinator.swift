//
//  Coordinator.swift
//  NASAApp
//
//  Created by Piotr Nietrzebka on 20/12/2024.
//

import Foundation

public protocol Coordinator: AnyObject {
    var coordinators: [Coordinator] { get set }
}

public extension Coordinator {
    func addCoordinator(_ coordinator: Coordinator) {
        coordinators.append(coordinator)
    }

    func removeCoordinator(_ coordinator: Coordinator) {
        assert(coordinator !== self)
        guard coordinator !== self else { return }
        coordinators = coordinators.filter { $0 !== coordinator }
    }

    func removeAllCoordinators() {
        coordinators.removeAll()
    }

    private func coordinatorOfType<T: Coordinator>(coordinator: Coordinator, type: T.Type) -> T? {
        if let value = coordinator as? T {
            return value
        } else {
            return coordinator.coordinators.compactMap { coordinatorOfType(coordinator: $0, type: type) }.first
        }
    }

    func coordinatorOfType<T: Coordinator>(type: T.Type) -> T? {
        return coordinatorOfType(coordinator: self, type: type)
    }
}
