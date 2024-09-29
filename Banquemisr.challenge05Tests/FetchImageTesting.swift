//
//  FetchImageTesting.swift
//  Banquemisr.challenge05Tests
//
//  Created by ios on 29/09/2024.
//

import XCTest
import Combine
@testable import Banquemisr_challenge05



class FetchingImagesTests: XCTestCase {
    
    var cancellables: Set<AnyCancellable>!
    var mockFetcher: MockImageFetcher!
    
    override func setUp() {
        super.setUp()
        cancellables = []
        mockFetcher = MockImageFetcher()
    }
    
    override func tearDown() {
        cancellables = nil
        mockFetcher = nil
        super.tearDown()
    }
    
    func testFetchImageSuccess() {
        // Given
        let expectedData = "Mock image data".data(using: .utf8)
        mockFetcher.mockData = expectedData
        
        let movie = Moviie(id: 1, backdropPath: "", originalLanguage: "en", overview: "Overview", releaseDate: "2023-01-01", title: "Title", voteAverage: 8.0, voteCount: 100, posterPath: "poster.jpg")
        
        // When
        let expectation = XCTestExpectation(description: "Fetch image data")
        
        mockFetcher.fetchImage(for: movie)
            .sink(receiveCompletion: { completion in
                if case .failure = completion {
                    XCTFail("Expected success but got failure")
                }
            }, receiveValue: { data in
                XCTAssertEqual(data, expectedData, "The fetched image data should match the expected data.")
                expectation.fulfill()
            })
            .store(in: &cancellables)
        
        // Then
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testFetchImageFailure() {
        // Given
        mockFetcher.mockError = NSError(domain: "TestError", code: 1, userInfo: nil)
        
        let movie = Moviie(id: 1, backdropPath: nil, originalLanguage: "en", overview: "Overview", releaseDate: "2023-01-01", title: "Title", voteAverage: 8.0, voteCount: 100, posterPath: "invalidPoster.jpg")
        
        // When
        let expectation = XCTestExpectation(description: "Handle image fetch failure")
        
        mockFetcher.fetchImage(for: movie)
            .sink(receiveCompletion: { completion in
                if case .failure = completion {
                    expectation.fulfill() // Fulfill the expectation on error
                } else {
                    XCTFail("Expected failure but got success")
                }
            }, receiveValue: { data in
                XCTAssertNil(data, "The fetched image data should be nil on failure.")
            })
            .store(in: &cancellables)
        
        // Then
        wait(for: [expectation], timeout: 2.0)
    }
}

// MockURLProtocol to simulate network responses
class MockURLProtocoll: URLProtocol {
    static var requestHandler: ((URLRequest) -> (HTTPURLResponse, Data?))?
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            XCTFail("Handler is unavailable.")
            return
        }
        
        let (response, data) = handler(request)
        self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        self.client?.urlProtocol(self, didLoad: data)
        
        self.client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {}
    
    static func register() {
        URLProtocol.registerClass(MockURLProtocol.self)
    }
    
    static func unregister() {
        URLProtocol.unregisterClass(MockURLProtocol.self)
    }
}
