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

protocol HomeViewModelType: VCViewModel {
    func transform(input: HomeViewModelInput) -> HomeViewModelOutput
}

class HomeViewModel: HomeViewModelType {
    private var cancellables: [AnyCancellable] = []
    private let feedService: FeedServiceType
    private var dateEnd: Date = Date()
    var isLoadingMore = false
    
    var homeSectionViewModels = [HomeSectionViewModel]()
    var hidesBackButton: Bool {
        true
    }
    
    var title: String {
        return String(localized: "title.home")
    }
    
    init(feedService: FeedServiceType) {
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
                    guard let feed = feed,
                        let objects = feed.nearEarthObjects else {
                            return .failure(NASAError.emptyFeed)
                          }
                    homeSectionViewModels = [HomeSectionViewModel]()
                    for key in objects.keys {
                        if let date = Date.apiFormatter.date(from: key),
                           let neos = objects[key] {
                            homeSectionViewModels.append(HomeSectionViewModel(date: date,
                                                                              nearEarthObjects: neos))
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
            .map({ [unowned self] (result: Result<Feed?, Error>) -> HomeViewModel.ViewState in
                switch result {
                case .success(let feed):
                    guard let feed = feed,
                          let objects = feed.nearEarthObjects else {
                        return .failure(NASAError.emptyFeed)
                    }
                    dateEnd = dateEnd.dayBefore
                    for key in objects.keys {
                        if let date = Date.apiFormatter.date(from: key),
                           let neos = objects[key] {
                            homeSectionViewModels.append(HomeSectionViewModel(date: date,
                                                                              nearEarthObjects: neos))
                        }
                    }
                    isLoadingMore = false
                    return .success(homeSectionViewModels)
                case .failure(let error): return .failure(error)
                }
            })
            .eraseToAnyPublisher()

        return .init(viewState: Publishers.Merge(refreshFeed, loadMoreFeed).eraseToAnyPublisher())
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

// MARK: - Mock

class HomeViewModelMock: HomeViewModelType {
    var homeSectionViewModels: [HomeSectionViewModel] = []
    var isDataLoaded = false

    func transform(input: HomeViewModelInput) -> HomeViewModelOutput {
        isDataLoaded = true
        return HomeViewModelOutput(viewState: Just(.success(homeSectionViewModels))
            .eraseToAnyPublisher())
    }
}
