//
//  NetworkManagerTesting.swift
//  Banquemisr.challenge05Tests
//
//  Created by ios on 29/09/2024.
//

import XCTest
import Combine
@testable import Banquemisr_challenge05

class NetworkManagerTests: XCTestCase {

    var networkManager: NetworkManager!
    var mockURLManager: MockURLManager!
    var cancellables: Set<AnyCancellable>!
    
    override func setUpWithError() throws {
        mockURLManager = MockURLManager()
        networkManager = NetworkManager()
        networkManager.urlManager = mockURLManager
        cancellables = []
        
        // Replace URLSession.shared with a mock
        URLProtocol.registerClass(MockURLProtocol.self)
    }

    override func tearDownWithError() throws {
        networkManager = nil
        cancellables = nil
        URLProtocol.unregisterClass(MockURLProtocol.self)
    }

    // MARK: - Test Cases
    
    func testFetchSuccess() throws {
        // Arrange
        let mockData = """
        {
            "id": 123,
            "title": "Test Movie"
        }
        """.data(using: .utf8)!
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!,
                                           statusCode: 200,
                                           httpVersion: nil,
                                           headerFields: nil)!
            return (response, mockData)
        }

        let expectation = XCTestExpectation(description: "Successful Fetch")
        
        // Act
        networkManager.fetch(url: mockURLManager.getFullURL(details: "movie", movieID: 123)!, type: Moviee.self)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    XCTFail("Expected success but got failure with error \(error)")
                }
            }, receiveValue: { movie in
                // Assert
                XCTAssertEqual(movie.id, 123)
                XCTAssertEqual(movie.title, "Test Movie")
                expectation.fulfill()
            })
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }

    func testFetchFailure_InvalidURL() throws {
        // Arrange
        mockURLManager.shouldReturnValidURL = false // Force invalid URL
        let expectation = XCTestExpectation(description: "Fetch with Invalid URL should fail")

        // Act
        networkManager.fetch(url: mockURLManager.getFullURL(details: "invalidURL") ?? "", type: Moviee.self)
            .sink(receiveCompletion: { completion in
                // Assert
                if case .failure(let error) = completion {
                    XCTAssertTrue(error is URLError, "Expected URLError but got \(error)")
                    expectation.fulfill()
                } else {
                    XCTFail("Expected failure but got success")
                }
            }, receiveValue: { _ in
                XCTFail("Expected no value")
            })
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFetchFailure_DecodingError() throws {
        // Arrange
        let invalidMockData = """
        {
            "invalid_field": "This is not valid"
        }
        """.data(using: .utf8)!

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!,
                                           statusCode: 200,
                                           httpVersion: nil,
                                           headerFields: nil)!
            return (response, invalidMockData)
        }

        let expectation = XCTestExpectation(description: "Fetch should fail due to decoding error")
        
        // Act
        networkManager.fetch(url: mockURLManager.getFullURL(details: "movie", movieID: 123)!, type: Moviee.self)
            .sink(receiveCompletion: { completion in
                // Assert
                if case .failure(let error) = completion {
                    XCTAssertTrue(error is DecodingError, "Expected DecodingError but got \(error)")
                    expectation.fulfill()
                } else {
                    XCTFail("Expected decoding error but got success")
                }
            }, receiveValue: { _ in
                XCTFail("Expected no value")
            })
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFetchFailure_HTTPError500() throws {
        // Arrange
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!,
                                           statusCode: 500,
                                           httpVersion: nil,
                                           headerFields: nil)!
            return (response, Data())
        }

        let expectation = XCTestExpectation(description: "Fetch should fail with HTTP 500 error")
        
        // Act
        networkManager.fetch(url: mockURLManager.getFullURL(details: "movie", movieID: 123)!, type: Moviee.self)
            .sink(receiveCompletion: { completion in
                // Assert
                if case .failure(let error) = completion {
                    XCTAssertTrue(error is URLError, "Expected URLError but got \(error)")
                    expectation.fulfill()
                } else {
                    XCTFail("Expected failure but got success")
                }
            }, receiveValue: { _ in
                XCTFail("Expected no value")
            })
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }

    func testFetchTimeout() throws {
        // Arrange
        MockURLProtocol.requestHandler = { request in
            // Simulate timeout by delaying the response
            let delay = 6.0 // Simulate delay of 6 seconds, which will cause a timeout
            Thread.sleep(forTimeInterval: delay)
            let response = HTTPURLResponse(url: request.url!,
                                           statusCode: 200,
                                           httpVersion: nil,
                                           headerFields: nil)!
            return (response, Data())
        }

        let expectation = XCTestExpectation(description: "Fetch should fail with timeout error")
        
        // Act
        networkManager.fetch(url: mockURLManager.getFullURL(details: "movie", movieID: 123)!, type: Moviee.self)
            .sink(receiveCompletion: { completion in
                // Assert
                if case .failure(let error) = completion {
                    XCTAssertTrue(error is URLError, "Expected URLError due to timeout but got \(error)")
                    expectation.fulfill()
                } else {
                    XCTFail("Expected timeout failure but got success")
                }
            }, receiveValue: { _ in
                XCTFail("Expected no value")
            })
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 7.0) // Timeout set to 7 seconds
    }
}

// MARK: - MockURLProtocol

class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            XCTFail("Request handler is unavailable.")
            return
        }

        let (response, data) = handler(request)
        self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        self.client?.urlProtocol(self, didLoad: data)
        self.client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() { }
}

// MARK: - Movie Model

struct Moviee: Codable {
    let id: Int
    let title: String
}
