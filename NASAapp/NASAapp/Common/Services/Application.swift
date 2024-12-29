//
//  Application.swift
//  NASAApp
//
//  Created by Piotr Nietrzebka on 20/12/2024.
//

import Foundation
import Combine

class Application {
    let environment: Configuration.Environment
    let dependencies: Dependencies
    
    static let shared: Application = {
        var env = Configuration.Environment.dev
        if CommandLine.arguments.contains("--UITest") {
            env = .xctests
        }
        
        return Application(environment: env)
    }()
    
    init(environment: Configuration.Environment = .dev) {
        self.environment = environment
        self.dependencies = Application.dependencies(with: environment)
    }
}

extension Application: DependenciesProvidable {
    internal static func dependencies(with environment: Configuration.Environment) -> Dependencies {
        switch environment {
        case .dev:
            return Dependencies(feedService: FeedService(NASAAPIKey: environment.apiKey))
        case .prod:
            return Dependencies(feedService: FeedService(NASAAPIKey: environment.apiKey))
        case .xctests:
            return Dependencies(feedService: FeedServiceMock())
        }
    }
}
