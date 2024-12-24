//
//  HomeViewModel.swift
//  NASAApp
//
//  Created by Piotr Nietrzebka on 20/12/2024.
//

import UIKit
import Combine

struct HomeViewModelInput {
    let onRefresh: AnyPublisher<Void, Never>
    let onLoadMore: AnyPublisher<Void, Never>
}

struct HomeViewModelOutput {
    let viewState: AnyPublisher<HomeViewModel.ViewState, Never>
}

class HomeViewModel: VCViewModel {
    private var cancellables: [AnyCancellable] = []
    private let feedService: FeedService
    private var dateEnd: Date = Date()
    var isLoadingMore = false
    
    var homeSectionViewModels = [HomeSectionViewModel]()
    var hidesBackButton: Bool {
        true
    }
    
    var title: String {
        return String(localized: "title.home")
    }
    
    init(feedService: FeedService) {
        self.feedService = feedService
    }
    
    func transform(input: HomeViewModelInput) -> HomeViewModelOutput {
        let refreshFeed = input.onRefresh
            .flatMapLatest({ [unowned self] _ in
                
                dateEnd = Date()
                
                return feedService.getFeedbyDate(dateEnd: dateEnd)
            })
            .map({ [unowned self] result -> HomeViewModel.ViewState in
                switch result {
                case .success(let feed):
                    homeSectionViewModels = [HomeSectionViewModel]()
                    
                    if let feed = feed,
                       let objects = feed.near_earth_objects {
                        
                        for key in objects.keys {
                            if let date = Date.apiFormatter.date(from: key),
                               let neos = objects[key] {
                                homeSectionViewModels.append(HomeSectionViewModel(date: date,
                                                                                  nearEarthObjects: neos))
                            }
                        }
                    }
                    
                    return .success(homeSectionViewModels)
                case .failure(let error): return .failure(error)
                }
            })
            .eraseToAnyPublisher()
        
        let loadMoreFeed = input.onLoadMore
            .flatMapLatest({ [unowned self] _ in
                isLoadingMore = true

                return feedService.getFeedbyDate(dateEnd: dateEnd.dayBefore)
            })
            .map({ [unowned self] result -> HomeViewModel.ViewState in
                switch result {
                case .success(let feed):
                    
                    dateEnd = dateEnd.dayBefore
                    
                    if let feed = feed,
                       let objects = feed.near_earth_objects {
                        
                        for key in objects.keys {
                            if let date = Date.apiFormatter.date(from: key),
                               let neos = objects[key] {
                                homeSectionViewModels.append(HomeSectionViewModel(date: date,
                                                                                  nearEarthObjects: neos))
                            }
                        }
                    }

                    isLoadingMore = false
                    return .success(homeSectionViewModels)
                case .failure(let error): return .failure(error)
                }
            })
            .eraseToAnyPublisher()
        
        let merge = Publishers.Merge(refreshFeed, loadMoreFeed).eraseToAnyPublisher()
        
        return .init(viewState: merge)
    }
}

extension HomeViewModel {
    enum ViewState: Equatable {
        case success([HomeSectionViewModel])
        case failure(Error)
        
        static func == (lhs: HomeViewModel.ViewState, rhs: HomeViewModel.ViewState) -> Bool {
            switch (lhs, rhs) {
            case (.success, .success): return true
            case (.failure, .failure): return true
            default: return false
            }
        }
    }
}
