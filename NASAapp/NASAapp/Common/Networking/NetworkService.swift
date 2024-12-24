//
//  NetworkingEngine.swift
//  NASAApp
//
//  Created by Piotr Nietrzebka on 20/12/2024.
//

import Foundation
import Combine

import Foundation
import Combine

protocol NetworkServiceType: AnyObject {

    @discardableResult
    func load<T>(_ resource: Resource<T>) -> AnyPublisher<T, Error>
}

enum NetworkError: Error {
    case invalidRequest
    case invalidResponse
    case dataLoadingError(statusCode: Int, data: Data)
    case jsonDecodingError(error: Error)
}

class NetworkService: NetworkServiceType {
    private let session: URLSession
    private let NASAAPIKey: String

    init(session: URLSession = URLSession(configuration: URLSessionConfiguration.ephemeral),
         NASAAPIKey: String) {
        self.session = session
        self.NASAAPIKey = NASAAPIKey
    }

    @discardableResult
    func load<T>(_ resource: Resource<T>) -> AnyPublisher<T, Error> {
        guard var request = resource.request else {
            return .fail(NetworkError.invalidRequest)
        }

        request.url?.append(queryItems: [URLQueryItem(name: "api_key",
                                                      value: "11uSQUbKvLbf81gXPEcdvtRyGRivnV0XIkigjoRC")])
        
        return session.dataTaskPublisher(for: request)
            .mapError { _ in NetworkError.invalidRequest }
            .flatMap { data, response -> AnyPublisher<Data, Error> in
                guard let response = response as? HTTPURLResponse else {
                    return .fail(NetworkError.invalidResponse)
                }

                guard 200..<300 ~= response.statusCode else {
                    debugPrint("response string \(String(describing: String(data: data, encoding: .utf8)))")
                    return .fail(NetworkError.dataLoadingError(statusCode: response.statusCode, data: data))
                }
                return .just(data)
            }
            .decode(type: T.self, decoder: JSONDecoder())
        .eraseToAnyPublisher()
    }

}
