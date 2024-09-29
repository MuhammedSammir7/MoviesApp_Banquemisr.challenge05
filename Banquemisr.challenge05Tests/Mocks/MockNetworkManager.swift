//
//  MockNetworkManager.swift
//  Banquemisr.challenge05Tests
//
//  Created by ios on 29/09/2024.
//

import XCTest
import Combine
@testable import Banquemisr_challenge05


class MockNetworkManager: NetworkManagerProtocol {
    var shouldFail = false
    var mockError: Error?
    var mockMoviesResponse: MoviesResponse?
    var mockMovieDetailsResponse: MovieDetailsResponse?

    func fetch<T>(url: String, type: T.Type) -> AnyPublisher<T, Error> where T: Decodable {
        if shouldFail {
            return Fail(error: mockError ?? NSError(domain: "Network Error", code: -1, userInfo: nil))
                .eraseToAnyPublisher()
        }

        if let response = mockMovieDetailsResponse as? T {
            return Just(response)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        } else if let response = mockMoviesResponse as? T {
            return Just(response)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }

        return Fail(error: URLError(.badServerResponse))
            .eraseToAnyPublisher()
    }
}
