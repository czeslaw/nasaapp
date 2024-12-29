//
//  Dependencies.swift
//  NASAApp
//
//  Created by Piotr Nietrzebka on 20/12/2024.
//

import Foundation

protocol DependenciesProvidable: AnyObject {
    static func dependencies(with environment: Configuration.Environment) -> Dependencies
}

struct Dependencies {
    let feedService: FeedServiceType
}
