//
//  AppCoordinator.swift
//  NASAApp
//
//  Created by Piotr Nietrzebka on 20/12/2024.
//

import UIKit

class AppCoordinator: NSObject, Coordinator {
    private let application: Application
    private let window: UIWindow
    let navigationController: UINavigationController
    
    var coordinators: [Coordinator] = []
    
    private lazy var homeCoordinator: HomeCoordinator = {
        let homeCoordinator = HomeCoordinator(navigationController: navigationController, 
                                              feedService: application.dependencies.feedService)
        return homeCoordinator
    }()
    
    init(application: Application,
         window: UIWindow) {

        let navigationController: UINavigationController = .withOverridenBarAppearence()
        navigationController.view.backgroundColor = Configuration.Color.defaultViewBackground
        
        self.application = application
        self.navigationController = navigationController
        self.window = window

        super.init()
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }

    func start(launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) {
        addCoordinator(homeCoordinator)
        homeCoordinator.start()
    }
}
