//
//  MockURL.swift
//  Banquemisr.challenge05Tests
//
//  Created by ios on 29/09/2024.
//
@testable import Banquemisr_challenge05
import Foundation

class MockURLManager: URLManagerProtocol {
    var shouldReturnValidURL = true
    var mockURL: String = "https://mockurl.com"
    func getFullURL(details: String, movieID: Int = 0) -> String? {
        if shouldReturnValidURL {
            return "https://mockapi.themoviedb.org/3/movie/\(movieID)"
        } else {
            return nil
        }
    }

    func getFullURL(details: String, movieID: Int) -> String {
        return mockURL
    }
}
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
                fatalError("Handler is unavailable.")
            }
            
            let (response, data) = handler(request)
            self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            self.client?.urlProtocol(self, didLoad: data)
            self.client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {
      
        }
    }
