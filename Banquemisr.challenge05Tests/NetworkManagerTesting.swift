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
        
       
        networkManager.fetch(url: mockURLManager.getFullURL(details: "movie", movieID: 123)!, type: Moviee.self)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    XCTFail("Expected success but got failure with error \(error)")
                }
            }, receiveValue: { movie in
     
                XCTAssertEqual(movie.id, 123)
                XCTAssertEqual(movie.title, "Test Movie")
                expectation.fulfill()
            })
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 3.0)
    }

    func testFetchFailure_InvalidURL() throws {
      
        mockURLManager.shouldReturnValidURL = false
        let expectation = XCTestExpectation(description: "Fetch with Invalid URL should fail")

       
        networkManager.fetch(url: mockURLManager.getFullURL(details: "invalidURL") ?? "", type: Moviee.self)
            .sink(receiveCompletion: { completion in
             
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
        
      
        networkManager.fetch(url: mockURLManager.getFullURL(details: "movie", movieID: 123)!, type: Moviee.self)
            .sink(receiveCompletion: { completion in
              
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

        wait(for: [expectation], timeout: 3.0)
    }
    
    func testFetchFailure_HTTPError500() throws {
       
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!,
                                           statusCode: 500,
                                           httpVersion: nil,
                                           headerFields: nil)!
            return (response, Data())
        }

        let expectation = XCTestExpectation(description: "Fetch should fail with HTTP 500 error")
        
    
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

        wait(for: [expectation], timeout: 3.0)
    }

    func testFetchTimeout() throws {
        // Arrange
        MockURLProtocol.requestHandler = { request in
            
            let delay = 6.0
            Thread.sleep(forTimeInterval: delay)
            let response = HTTPURLResponse(url: request.url!,
                                           statusCode: 200,
                                           httpVersion: nil,
                                           headerFields: nil)!
            return (response, Data())
        }

        let expectation = XCTestExpectation(description: "Fetch should fail with timeout error")
        
    
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

        wait(for: [expectation], timeout: 7.0)
    }
}


struct Moviee: Codable {
    let id: Int
    let title: String
}
