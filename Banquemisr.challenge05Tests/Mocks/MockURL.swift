//
//  MockURL.swift
//  Banquemisr.challenge05Tests
//
//  Created by ios on 29/09/2024.
//
@testable import Banquemisr_challenge05

class MockURLManager: URLManagerProtocol {
    var shouldReturnValidURL = true

    func getFullURL(details: String, movieID: Int = 0) -> String? {
        if shouldReturnValidURL {
            return "https://mockapi.themoviedb.org/3/movie/\(movieID)"
        } else {
            return nil // Simulates a case where an invalid URL is returned
        }
    }
}
