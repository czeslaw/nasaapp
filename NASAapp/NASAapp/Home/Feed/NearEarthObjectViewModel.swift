//
//  DrinkViewModel.swift
//  NASAApp
//
//  Created by Piotr Nietrzebka on 20/12/2024.
//

import Foundation
import Combine
import UIKit

struct NearEarthObjectViewModelInput {
    let onAppear: AnyPublisher<Void, Never>
}

struct NearEarthObjectViewModelOutput {
    let viewState: AnyPublisher<NearEarthObjectViewModel.ViewState, Never>
}

class NearEarthObjectViewModel: VCViewModel {
    struct NearEarthObjectCellViewModel {
        let title: String
        let detail: String
        
        static func create(key: String?, value: Any?) -> NearEarthObjectCellViewModel? {
            guard let key = key,
                  let value = value as? String else {
                return nil
            }

            return NearEarthObjectCellViewModel(title: key.replacingOccurrences(of: "_", with: " "),
                                                detail: value)
        }
    }
    
    private var cancellables: [AnyCancellable] = []
    private let onPressShare = PassthroughSubject<Void, Never>()
    let feedService: FeedService
    var nearEarthObject: NearEarthObject

    var cellViewModels = [NearEarthObjectCellViewModel]()
    
    var title: String {
        return nearEarthObject.name ?? String(localized: "noName")
    }
    
    var rightBarButtonItemImage: UIImage? {
        return UIImage(systemName: "square.and.arrow.up")?.withRenderingMode(.alwaysTemplate)
    }
    
    init(nearEarthObject: NearEarthObject,
         feedService: FeedService) {
        self.nearEarthObject = nearEarthObject
        self.feedService = feedService
    }
    
    func transform(input: NearEarthObjectViewModelInput) -> NearEarthObjectViewModelOutput {
        let fetchFeed = input.onAppear
            .flatMapLatest({ [unowned self] query in feedService.getFeedObject(with: "") })
            .map({ result -> NearEarthObjectViewModel.ViewState in
                switch result {
                case .success(let feed):
                    
//                    nearEarthObjects.compactMapKeys( { Date.apiFormatter.date(from: $0)} ))
                    
//                    do {
//                        self.cellViewModels.removeAll()
//                        let allProperties = try feed.allProperties()
//
//                        allProperties.keys.sorted { k1, k2 in
//                            return k1.compare(k2) == ComparisonResult.orderedAscending
//                        }
//                        .forEach { key in
//                            if let cell = FeedCellViewModel.create(key: key,
//                                                                    value: allProperties[key]) {
//                                self.cellViewModels.append(cell)
//                            }
//                        }
//                    } catch _ {
//
//                    }
                    
                    return .success(feed)
                case .failure(let error):
                    return .failure(error)
                }
            })
        
        let share = onPressShare
            .map({ [unowned self] result -> NearEarthObjectViewModel.ViewState in
                return .share(self.nearEarthObject)
            })

        let merge = Publishers.Merge(fetchFeed, share).removeDuplicates().eraseToAnyPublisher()
        
        return .init(viewState: merge)
    }
    
    func rightBarButtonItemAction() {
        onPressShare.send()
    }
}

extension NearEarthObjectViewModel {
    enum ViewState: Equatable {
        case success(NearEarthObject?)
        case failure(Error)
        case share(NearEarthObject)
        
        static func == (lhs: NearEarthObjectViewModel.ViewState, rhs: NearEarthObjectViewModel.ViewState) -> Bool {
            switch (lhs, rhs) {
            case (.share, .share): return true
            case (.success(let lhsNEO), .success(let rhsNEO)): return lhsNEO?.id == rhsNEO?.id
            case (.failure, .failure): return true
            default: return false
            }
        }
    }
}
