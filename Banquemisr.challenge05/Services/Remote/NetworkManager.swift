//
//  NetworkManager.swift
//  Banquemisr.challenge05
//
//  Created by ios on 27/09/2024.
//

import Foundation
import Combine

class NetworkManager: NetworkManagerProtocol {
    var urlManager: URLManagerProtocol?
    
    init() {
        self.urlManager = URLManager()
    }
    
    func fetch<T: Codable>(url: String, type: T.Type) -> AnyPublisher<T, Error> {
        
        guard let url = URL(string: url) else {
            return Fail(error: URLError(.badURL))
                .eraseToAnyPublisher()
        }
        
        print("url : \(url)")
        
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return Fail(error: URLError(.badURL))
                .eraseToAnyPublisher()
        }
        
        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "language", value: "en-US"),
            URLQueryItem(name: "page", value: "1"),
            URLQueryItem(name: "api_key", value: "d68524e0df00f5cb6705767f52121331")
        ]
        components.queryItems = (components.queryItems ?? []) + queryItems
        
        guard let componentsURL = components.url else {
            return Fail(error: URLError(.badURL))
                .eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: componentsURL)
        request.httpMethod = "GET"
        request.timeoutInterval = 5
        request.allHTTPHeaderFields = ["accept": "application/json"]
        request.cachePolicy = .reloadIgnoringLocalCacheData

        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { result -> Data in
                guard let response = result.response as? HTTPURLResponse,
                      (200...299).contains(response.statusCode) else {
                    throw URLError(.badServerResponse)
                }
                return result.data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .subscribe(on: DispatchQueue.global(qos: .background))
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
