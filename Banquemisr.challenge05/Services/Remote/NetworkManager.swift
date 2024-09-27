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
        // 1. Create the URL and components
        guard let url = URL(string: url) else {
            return Fail(error: URLError(.badURL))
                .eraseToAnyPublisher()
        }
        
        print("url : \(url)")
        
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return Fail(error: URLError(.badURL))
                .eraseToAnyPublisher()
        }
        
        // 2. Add query parameters
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
        request.timeoutInterval = 10
        request.allHTTPHeaderFields = ["accept": "application/json"]
        
        // 3. Use Combine to create a publisher
        return URLSession.shared.dataTaskPublisher(for: request)
            // 4. Handle the response and ensure it's valid
            .tryMap { result -> Data in
                guard let response = result.response as? HTTPURLResponse,
                      (200...299).contains(response.statusCode) else {
                    throw URLError(.badServerResponse)
                }
                return result.data
            }
            // 5. Decode the JSON response into the expected model
            .decode(type: T.self, decoder: JSONDecoder())
            // 6. Ensure that the publisher operates on a background thread and delivers results on the main thread
            .subscribe(on: DispatchQueue.global(qos: .background))
            .receive(on: DispatchQueue.main)
            // 7. Convert the publisher to an `AnyPublisher` to avoid leaking implementation details
            .eraseToAnyPublisher()
    }
}
