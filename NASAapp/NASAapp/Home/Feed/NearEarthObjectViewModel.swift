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

protocol NearEarthObjectViewModelType: VCViewModel {
    var nearEarthObject: NearEarthObject { get set }
    var cellViewModels: [NearEarthObjectCellViewModel] { get set }
    func transform(input: NearEarthObjectViewModelInput) -> NearEarthObjectViewModelOutput
    func updateCellViewModels()
}

class NearEarthObjectViewModel: NearEarthObjectViewModelType {
    private var cancellables: [AnyCancellable] = []
    private let onPressShare = PassthroughSubject<Void, Never>()
    let feedService: FeedServiceType
    var nearEarthObject: NearEarthObject
    var cellViewModels = [NearEarthObjectCellViewModel]()
    
    var title: String {
        return nearEarthObject.name ?? String(localized: "noName")
    }
    
    var rightBarButtonItemImage: UIImage? {
        return UIImage(systemName: "square.and.arrow.up")?.withRenderingMode(.alwaysTemplate)
    }
    
    init(nearEarthObject: NearEarthObject,
         feedService: FeedServiceType) {
        self.nearEarthObject = nearEarthObject
        self.feedService = feedService
        updateCellViewModels()
    }

    func transform(input: NearEarthObjectViewModelInput) -> NearEarthObjectViewModelOutput {
        let fetchFeed = input.onAppear
            .flatMapLatest({ [unowned self] _ in feedService.getFeedObject(with: nearEarthObject.id ?? "") })
            .map({ result -> NearEarthObjectViewModel.ViewState in
                switch result {
                case .success(let nearEarthObject):
                    if let nearEarthObject = nearEarthObject {
                        self.nearEarthObject = nearEarthObject
                        self.updateCellViewModels()
                    }
                    return .success(nearEarthObject)
                case .failure(let error):
                    return .failure(error)
                }
            })
        
        let share = onPressShare
            .map({ [unowned self] _ -> NearEarthObjectViewModel.ViewState in
                return .share(self.nearEarthObject)
            })

        let merge = Publishers.Merge(fetchFeed, share).removeDuplicates().eraseToAnyPublisher()
        
        return .init(viewState: merge)
    }
    
    func rightBarButtonItemAction() {
        onPressShare.send()
    }
    
    func updateCellViewModels() {
        do {
            self.cellViewModels.removeAll()
            let allProperties = try self.nearEarthObject.allProperties()

            allProperties.keys.sorted { key1, key2 in
                return key1.compare(key2) == ComparisonResult.orderedAscending
            }
            .forEach { key in
                if let cell = NearEarthObjectCellViewModel.create(key: key,
                                                        value: allProperties[key]) {
                    self.cellViewModels.append(cell)
                }
            }
        } catch _ {

        }
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

// MARK: - Mocks

class NearEarthObjectViewModelMock: NearEarthObjectViewModelType {
    var nearEarthObject: NearEarthObject = NearEarthObject.empty
    var cellViewModels: [NearEarthObjectCellViewModel] = [NearEarthObjectCellViewModel]()
    
    func transform(input: NearEarthObjectViewModelInput) -> NearEarthObjectViewModelOutput {
        let mockObject = NearEarthObject.empty
        
        let publisher = Just(mockObject)
            .map { NearEarthObjectViewModel.ViewState.success($0) }
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.loadData()
            })
            .eraseToAnyPublisher()

        return NearEarthObjectViewModelOutput(viewState: publisher)
    }

    var mockData: [NearEarthObject] = []
    var isDataLoaded = false

    func loadData() {
        self.updateCellViewModels()
        isDataLoaded = true
    }

    func numberOfItems() -> Int {
        return mockData.count
    }

    func item(at index: Int) -> NearEarthObject {
        return mockData[index]
    }
    
    func updateCellViewModels() {
        do {
            self.cellViewModels.removeAll()
            let allProperties = try self.nearEarthObject.allProperties()

            allProperties.keys.sorted { key1, key2 in
                return key1.compare(key2) == ComparisonResult.orderedAscending
            }
            .forEach { key in
                if let cell = NearEarthObjectCellViewModel.create(key: key,
                                                        value: allProperties[key]) {
                    self.cellViewModels.append(cell)
                }
            }
        } catch _ {

        }
    }
}

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
