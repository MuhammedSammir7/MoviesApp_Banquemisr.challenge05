//
//  MockFetchImage.swift
//  Banquemisr.challenge05Tests
//
//  Created by ios on 29/09/2024.
//
import XCTest
import Combine
@testable import Banquemisr_challenge05

protocol ImageFetcher {
    func fetchImage(for movie: Moviie) -> AnyPublisher<Data?, Error>
}
class MockImageFetcher: ImageFetcher {
    var mockData: Data?
    var mockError: Error?
    
    func fetchImage(for movie: Moviie) -> AnyPublisher<Data?, Error> {
        if let error = mockError {
            return Fail(error: error).eraseToAnyPublisher()
        }
        return Just(mockData).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
}
// Ensure your main Movie struct is accessible
struct Moviie {
    let id: Int
    let backdropPath: String?
    let originalLanguage: String
    let overview: String
    let releaseDate: String
    let title: String
    let voteAverage: Double
    let voteCount: Int
    let posterPath: String?
}
