//
//  FeedService.swift
//  NASAApp
//
//  Created by Piotr Nietrzebka on 20/12/2024.
//

import Foundation
import Combine

class FeedService: NetworkService {
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
        let parameters: [String : CustomStringConvertible] = [
            "start_date": dateEnd.apiFormat,
            "end_date": dateEnd.apiFormat,
            ]
        return Resource<Feed>(url: url, parameters: parameters)
    }

    static func nearEarthObject(identifier: String) -> Resource<NearEarthObjectResponse> {
        let url = URL(string: Application.shared.environment.rootURL.appending("lookup.php"))!
        let parameters: [String : CustomStringConvertible] = [
            "i": identifier,
        ]
        return Resource<NearEarthObjectResponse>(url: url, parameters: parameters)
    }
}
