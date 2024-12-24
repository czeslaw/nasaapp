//
//  Resource.swift
//  NASAApp
//
//  Created by Piotr Nietrzebka on 20/12/2024.
//

import Foundation

enum HTTPMethodType: String {
    case GET
    case POST
    case PATCH
    case PUT
    case DELETE
}

struct Resource<T: Decodable> {
    let method: HTTPMethodType
    let url: URL
    let parameters: [String: CustomStringConvertible]
    var request: URLRequest? {
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return nil
        }
        components.queryItems = parameters.keys.map { key in
            URLQueryItem(name: key, value: parameters[key]?.description)
        }
        guard let url = components.url else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content­-Type")
        
        return request
    }

    init(method: HTTPMethodType = .GET,
         url: URL,
         parameters: [String: CustomStringConvertible] = [:]) {
        self.method = method
        self.url = url
        self.parameters = parameters
    }
}
