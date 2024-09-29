//
//  MovieDetailsViewModelTesting.swift
//  Banquemisr.challenge05Tests
//
//  Created by ios on 29/09/2024.
//

import XCTest
import Combine
@testable import Banquemisr_challenge05 // Replace with your module name

// Mock Network Manager
class MockNetworkManager: NetworkManagerProtocol {
    var shouldFail = false
    var mockResponse: MovieDetailsResponse?
    
    func fetch<T>(url: String, type: T.Type) -> AnyPublisher<T, Error> where T : Decodable {
        if shouldFail {
            return Fail(error: NSError(domain: "Network Error", code: -1, userInfo: nil)).eraseToAnyPublisher()
        }
        
        let response: T = mockResponse as! T
        return Just(response)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}

// Mock URL Manager
class MockURLManagerr: URLManagerProtocol {
    func getFullURL(details: String, movieID: Int) -> String? {
        return "https://mock.url/\(details)/\(movieID)"
    }
    
}

class MovieDetailsViewModelTests: XCTestCase {
    
    var viewModel: MovieDetailsViewModel!
    var mockNetworkManager: MockNetworkManager!
    var mockURLManager: MockURLManager!
    
    override func setUpWithError() throws {
        mockNetworkManager = MockNetworkManager()
        mockURLManager = MockURLManager()
        viewModel = MovieDetailsViewModel()
        
        // Inject mocks
        viewModel.networkManager = mockNetworkManager
        viewModel.urlManager = mockURLManager
        viewModel.movieId = 1
    }
    
    override func tearDownWithError() throws {
        viewModel = nil
        mockNetworkManager = nil
        mockURLManager = nil
    }
    
    func testFetchMovieDetailsSuccess() {
        // Given
        let mockMovieDetails = MovieDetailsResponse(
            backdropPath: "/backdrop.jpg", genres: [Genre( name: "Action")], id: 1,
            originalLanguage: "en",
            originalTitle: "Mock Title", overview: "Mock overview",
            posterPath: "/poster.jpg",
            releaseDate: "2023-01-01",
            runtime: 120, voteAverage: 8.5, voteCount: 100
        )
        
        mockNetworkManager.mockResponse = mockMovieDetails
        
        // When
        let expectation = XCTestExpectation(description: "Fetch movie details")
        viewModel.$movie
            .dropFirst() // We only want to receive the new value
            .sink { movie in
                XCTAssertNotNil(movie)
                XCTAssertEqual(movie?.originalTitle, "Mock Title")
                expectation.fulfill()
            }
            .store(in: &viewModel.cancellables)
        
        viewModel.fetchMovieDetails()
        
        // Wait for expectations
        wait(for: [expectation], timeout: 1)
    }
    
    func testFetchMovieDetailsFailure() {
        // Given
        mockNetworkManager.shouldFail = true
        
        // When
        let expectation = XCTestExpectation(description: "Fetch movie details fails")
        viewModel.$movie
            .dropFirst() // We only want to receive the new value
            .sink { movie in
                XCTAssertNil(movie)
                expectation.fulfill()
            }
            .store(in: &viewModel.cancellables)
        
        viewModel.fetchMovieDetails()
        
        // Wait for expectations
        wait(for: [expectation], timeout: 2)
    }
    
    func testFetchPosterImage() {
        // Given
        let movieDetails = MovieDetailsResponse(backdropPath: "/backdrop.jpg", id: 1, originalLanguage: "en", originalTitle: "Mock Title", overview: "Mock overview", posterPath: "/poster.jpg", releaseDate: "2023-01-01", runtime: 120, voteAverage: 8.5, voteCount: 100)
        
        viewModel.movie = movieDetails
        
        // When
        let expectation = XCTestExpectation(description: "Fetch poster image")
        viewModel.fetchPosterImage()
            .sink(receiveValue: { image in
                XCTAssertNotNil(image) // Assuming the image at the URL is valid
                expectation.fulfill()
            })
            .store(in: &viewModel.cancellables)
        
        // Wait for expectations
        wait(for: [expectation], timeout: 2)
    }
    
    func testLoadDataFromCoreData() {
        // This test should mock the PersistenceManager's method to return a stored movie
        // and then verify that the view model's movie property is updated correctly.
        
        // Assuming you have a way to set up the PersistenceManager mock
        // This test requires further implementation based on your Core Data setup.
    }
}

