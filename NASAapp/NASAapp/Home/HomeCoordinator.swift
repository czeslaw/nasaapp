//
//  HomeCoordinator.swift
//  NASAApp
//
//  Created by Piotr Nietrzebka on 20/12/2024.
//

import Foundation
import UIKit

protocol HomeCoordinatorDelegate: AnyObject {
}

class HomeCoordinator: Coordinator {
    private let navigationController: UINavigationController
    private let feedService: FeedServiceType
    var coordinators: [Coordinator] = []
    
    weak var delegate: HomeCoordinatorDelegate?

    init(navigationController: UINavigationController,
         feedService: FeedServiceType) {
        self.navigationController = navigationController
        self.feedService = feedService
    }
    
    private lazy var rootViewController: HomeViewController = {
        let viewController = HomeViewController(viewModel: HomeViewModel(feedService: feedService))
        viewController.delegate = self
        return viewController
    }()
    
    private lazy var splashViewController: SplashViewController = {
        let viewController = SplashViewController(viewModel: BaseViewModel())
        viewController.delegate = self
        return viewController
    }()
    
    func start() {
        presentSplashVC()
    }
    
    func presentSplashVC() {
        navigationController.setNavigationBarHidden(true, animated: false)
        navigationController.setViewControllers([splashViewController], animated: true)
    }
    
    func presentHomeVC() {
        navigationController.setViewControllers([rootViewController], animated: true)
        navigationController.setNavigationBarHidden(false, animated: true)
    }
}

extension HomeCoordinator: HomeViewControllerDelegate {
    func onSelect(nearEarthObject: NearEarthObject) {
        let nearEarthObjectViewController =
        NearEarthObjectViewController(viewModel: NearEarthObjectViewModel(nearEarthObject: nearEarthObject,
                                                                          feedService: feedService))
        nearEarthObjectViewController.delegate = self
        navigationController.pushViewController(nearEarthObjectViewController, animated: true)
    }
}

extension HomeCoordinator: SplashViewControllerDelegate {
    func didFinishAnimating() {
        presentHomeVC()
    }
}

extension HomeCoordinator: NearEarthObjectViewControllerDelegate {
    func didPressShare(nearEarthObject: NearEarthObject) {
        var activityItems = [Any]()
        if let name = nearEarthObject.name {
            activityItems.append(name)
        }
        if let url = URL(string: nearEarthObject.nasaJplUrl ?? "") {
            activityItems.append(url)
        }

        let avc = UIActivityViewController(activityItems: activityItems,
                                           applicationActivities: nil)
        self.navigationController.present(avc, animated: true)
    }
}
