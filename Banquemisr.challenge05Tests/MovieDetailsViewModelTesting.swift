//
//  MovieDetailsViewModelTesting.swift
//  Banquemisr.challenge05Tests
//
//  Created by ios on 29/09/2024.
//

import XCTest
import Combine
@testable import Banquemisr_challenge05

class MovieDetailsViewModelTests: XCTestCase {
    
    var viewModel: MovieDetailsViewModel!
    var mockNetworkManager: MockNetworkManager!
    var mockURLManager: MockURLManager!
    
    override func setUpWithError() throws {
        mockNetworkManager = MockNetworkManager()
        mockURLManager = MockURLManager()
        viewModel = MovieDetailsViewModel()
        
        viewModel.networkManager = mockNetworkManager
        viewModel.urlManager = mockURLManager
        viewModel.movieId = 1
        URLProtocol.registerClass(MockURLProtocol.self)
    }
    
    override func tearDownWithError() throws {
        viewModel = nil
        mockNetworkManager = nil
        mockURLManager = nil
        URLProtocol.unregisterClass(MockURLProtocol.self)
    }
    
    func testFetchMovieDetailsSuccess() {
        // Given
        let mockMovieDetails = MovieDetailsResponse(
            backdropPath: "/backdrop.jpg",
            genres: [Genre(name: "Action")],
            id: 1,
            originalLanguage: "en",
            originalTitle: "Mock Title",
            overview: "Mock overview",
            posterPath: "/poster.jpg",
            releaseDate: "2023-01-01",
            runtime: 120,
            voteAverage: 8.5,
            voteCount: 100
        )
        
        mockNetworkManager.mockMovieDetailsResponse = mockMovieDetails
        
        let expectation = XCTestExpectation(description: "Fetch movie details")
        viewModel.$movie
            .dropFirst()
            .sink { movie in
                XCTAssertNotNil(movie)
                XCTAssertEqual(movie?.originalTitle, "Mock Title")
                expectation.fulfill()
            }
            .store(in: &viewModel.cancellables)
        
        viewModel.fetchMovieDetails()
        
        wait(for: [expectation], timeout: 2)
    }
    
    func testFetchPosterImage() {
        let movieDetails = MovieDetailsResponse(
            backdropPath: "/backdrop.jpg",
            genres: [Genre(name: "Action")],
            id: 1,
            originalLanguage: "en",
            originalTitle: "Mock Title",
            overview: "Mock overview",
            posterPath: "/poster.jpg",
            releaseDate: "2023-01-01",
            runtime: 120,
            voteAverage: 8.5,
            voteCount: 100
        )
        viewModel.movie = movieDetails
        
        let mockImageData = MockImageLoader.mockImageData()
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, mockImageData)
        }
        
        let expectation = XCTestExpectation(description: "Fetch poster image")
        
        viewModel.fetchPosterImage()
            .sink(receiveValue: { image in
                XCTAssertNotNil(image, "Image should not be nil")
                expectation.fulfill()
            })
            .store(in: &viewModel.cancellables)
        wait(for: [expectation], timeout: 2)
    }
   
    func testFetchPosterImageFailure() {
        // Given
        viewModel.movie = MovieDetailsResponse(
            backdropPath: "/backdrop.jpg",
            genres: [Genre(name: "Action")],
            id: 1,
            originalLanguage: "en",
            originalTitle: "Mock Title",
            overview: "Mock overview",
            posterPath: "/poster.jpg",
            releaseDate: "2023-01-01",
            runtime: 120,
            voteAverage: 8.5,
            voteCount: 100
        )
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 404, httpVersion: nil, headerFields: nil)!
            return (response, Data())
        }
        
        let expectation = XCTestExpectation(description: "Fetch poster image failure")
        
        viewModel.fetchPosterImage()
            .sink(receiveValue: { image in
                XCTAssertNil(image, "Image should be nil on failure")
                expectation.fulfill()
            })
            .store(in: &viewModel.cancellables)
        
        wait(for: [expectation], timeout: 2)
    }
    
    func testMockMovieDetailsFailure() {
        // Given
        let mockError = NSError(domain: "NetworkError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch movie details."])
        let mockViewModel = MockMovieDetailsViewModel(mockError: mockError)

        // Expectation for async error handling
        let expectation = XCTestExpectation(description: "Handle mock movie details failure")

        // Simulate binding
        mockViewModel.$errorMessage
            .sink { errorMessage in
                if let errorMessage = errorMessage {
                    XCTAssertNotNil(errorMessage, "Error message should not be nil")
                    XCTAssertEqual(errorMessage, "Failed to fetch movie details.", "Error message should match the expected string")
                    expectation.fulfill()
                }
            }
            .store(in: &mockViewModel.cancellables)

        // When
        mockViewModel.fetchMovieDetails()

        // Then
        wait(for: [expectation], timeout: 2)
    }



}

class MockImageLoader {
    static func mockImageData() -> Data {
        let size = CGSize(width: 100, height: 100)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { ctx in
            UIColor.red.setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
        }
        return image.pngData()!
    }
}

class MockMovieDetailsViewModel: ObservableObject {
    @Published var errorMessage: String?
    var cancellables = Set<AnyCancellable>()
    var mockError: NSError?
    
    init(mockError: NSError?) {
        self.mockError = mockError
    }
    
    func fetchMovieDetails() {
        // Simulating an error response
        if let error = mockError {
            self.errorMessage = error.localizedDescription
        }
    }
}
