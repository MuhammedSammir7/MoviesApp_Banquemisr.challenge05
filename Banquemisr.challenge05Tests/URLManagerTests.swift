//
//  URLManagerTests.swift
//  Banquemisr.challenge05Tests
//
//  Created by ios on 29/09/2024.
//

import XCTest
@testable import Banquemisr_challenge05

class URLManagerTests: XCTestCase {

    var urlManager: URLManager!

    override func setUpWithError() throws {
        // Initialize URLManager before each test
        urlManager = URLManager()
    }

    override func tearDownWithError() throws {
        // Deinitialize URLManager after each test
        urlManager = nil
    }

    func testGetFullURLForUpcoming() {
        // Arrange
        let expectedURL = "https://api.themoviedb.org/3/movie/upcoming"
        
        // Act
        let resultURL = urlManager.getFullURL(details: "upcoming", movieID: 0)
        
        // Assert
        XCTAssertEqual(resultURL, expectedURL, "The generated URL for upcoming movies is incorrect.")
    }

    func testGetFullURLForNowPlaying() {
        // Arrange
        let expectedURL = "https://api.themoviedb.org/3/movie/now_playing"
        
        // Act
        let resultURL = urlManager.getFullURL(details: "now_playing", movieID: 0)
        
        // Assert
        XCTAssertEqual(resultURL, expectedURL, "The generated URL for now playing movies is incorrect.")
    }

    func testGetFullURLForPopular() {
        // Arrange
        let expectedURL = "https://api.themoviedb.org/3/movie/popular"
        
        // Act
        let resultURL = urlManager.getFullURL(details: "popular", movieID: 0)
        
        // Assert
        XCTAssertEqual(resultURL, expectedURL, "The generated URL for popular movies is incorrect.")
    }

    func testGetFullURLForMovieDetails() {
        // Arrange
        let movieID = 12345
        let expectedURL = "https://api.themoviedb.org/3/movie/\(movieID)"
        
        // Act
        let resultURL = urlManager.getFullURL(details: "movie", movieID: movieID)
        
        // Assert
        XCTAssertEqual(resultURL, expectedURL, "The generated URL for movie details is incorrect.")
    }

    func testGetFullURLWithInvalidDetails() {
        // Arrange
        let expectedURL = "https://api.themoviedb.org/3/movie/upcoming"  // Defaults to upcoming if the detail is invalid
        
        // Act
        let resultURL = urlManager.getFullURL(details: "invalid_detail", movieID: 0)
        
        // Assert
        XCTAssertEqual(resultURL, expectedURL, "The generated URL for an invalid detail should default to upcoming movies.")
    }
}
