//
//  FeedService.swift
//  NASAApp
//
//  Created by Piotr Nietrzebka on 20/12/2024.
//

import Foundation
import Combine

protocol FeedServiceType {
    func getFeedbyDate(dateEnd: Date) -> AnyPublisher<Result<Feed?, Error>, Never>
    func getFeedObject(with identifier: String) -> AnyPublisher<Result<NearEarthObject?, Error>, Never>
}

class FeedService: NetworkService, FeedServiceType {
    private var cancellables = Set<AnyCancellable>()

    func getFeedbyDate(dateEnd: Date) -> AnyPublisher<Result<Feed?, Error>, Never> {
        return load(Resource<Feed>.feed(dateEnd: dateEnd))
            .map {
                return .success($0)
            }
            .catch { error -> AnyPublisher<Result<Feed?, Error>, Never> in .just(.failure(error)) }
            .eraseToAnyPublisher()
    }
    
    func getFeedObject(with identifier: String) -> AnyPublisher<Result<NearEarthObject?, Error>, Never> {
        return load(Resource<Feed>.nearEarthObject(identifier: identifier))
            .map {
                guard let nearEarthObject = $0.nearEarthObject else {
                    return .success(nil)
                }
                
                return .success(nearEarthObject)
            }
            .catch { error -> AnyPublisher<Result<NearEarthObject?, Error>, Never> in .just(.failure(error)) }
            .eraseToAnyPublisher()
    }
}

struct NearEarthObjectResponse: Decodable {
    let nearEarthObject: NearEarthObject?
}

extension Resource {
    static func feed(dateEnd: Date) -> Resource<Feed> {
        let url = URL(string: Application.shared.environment.rootURL.appending("feed"))!
        let parameters: [String: CustomStringConvertible] = [
            "start_date": dateEnd.apiFormat,
            "end_date": dateEnd.apiFormat
            ]
        return Resource<Feed>(url: url, parameters: parameters)
    }

    // swiftlint:disable:this force_unwrapping
    // FIXME: need additional authentication to explore this endpoint
    // "response string Optional(\"HTTP Status 401 - Full authentication is required to access this resource\\n\")"
    static func nearEarthObject(identifier: String) -> Resource<NearEarthObjectResponse> {
        let url = URL(string: Application.shared.environment.rootURL.appending("identifier"))!
        let parameters: [String: CustomStringConvertible] = [
            "i": identifier
        ]
        return Resource<NearEarthObjectResponse>(url: url, parameters: parameters)
    }
}

// MARK: - Mocks

class FeedServiceMock: FeedServiceType {
    var feedResponse: Result<Feed?, Error>?
    private var mockData: [NearEarthObject] = {
        return [NearEarthObject(links: nil,
                                id: "123",
                                name: "TestObject1",
                                neoReferenceId: nil,
                                nasaJplUrl: nil,
                                absoluteMagnitudeH: nil,
                                estimatedDiameter: nil,
                                isPotentiallyHazardousAsteroid: nil,
                                isSentryObject: nil,
                                closeApproachData: []),
                NearEarthObject(links: nil,
                                id: "456",
                                name: "TestObject2",
                                neoReferenceId: nil,
                                nasaJplUrl: nil,
                                absoluteMagnitudeH: nil,
                                estimatedDiameter: nil,
                                isPotentiallyHazardousAsteroid: nil,
                                isSentryObject: nil,
                                closeApproachData: [])]
    }()
    
    func getFeedbyDate(dateEnd: Date) -> AnyPublisher<Result<Feed?, any Error>, Never> {
        if let feedResponse = feedResponse {
            switch feedResponse {
            case .success(let feed):
                return Just(.success(feed)).eraseToAnyPublisher()
            case .failure(let error):
                return Just(.failure(error)).eraseToAnyPublisher()
            }
        }
        
        let mockFeed = Feed(
            links: nil,
            elementCount: 2,
            nearEarthObjects: [
                "2024-12-29": mockData
            ]
        )
        return Just(.success(mockFeed)).eraseToAnyPublisher()
    }
    
    func getFeedObject(with identifier: String) -> AnyPublisher<Result<NearEarthObject?, any Error>, Never> {
        let mockObject = NearEarthObject(links: nil,
                                         id: "123",
                                         name: "TestObject1",
                                         neoReferenceId: nil,
                                         nasaJplUrl: nil,
                                         absoluteMagnitudeH: nil,
                                         estimatedDiameter: nil,
                                         isPotentiallyHazardousAsteroid: nil,
                                         isSentryObject: nil,
                                         closeApproachData: [])
        return Just(.success(mockObject))
            .eraseToAnyPublisher()
    }
}
