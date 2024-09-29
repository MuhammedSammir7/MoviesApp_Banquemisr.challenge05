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
        urlManager = URLManager()
    }

    override func tearDownWithError() throws {
        urlManager = nil
    }

    func testGetFullURLForUpcoming() {
        let expectedURL = "https://api.themoviedb.org/3/movie/upcoming"
        
        let resultURL = urlManager.getFullURL(details: "upcoming", movieID: 0)
        
        XCTAssertEqual(resultURL, expectedURL, "The generated URL for upcoming movies is incorrect.")
    }

    func testGetFullURLForNowPlaying() {
        let expectedURL = "https://api.themoviedb.org/3/movie/now_playing"
        
        let resultURL = urlManager.getFullURL(details: "now_playing", movieID: 0)
        
        XCTAssertEqual(resultURL, expectedURL, "The generated URL for now playing movies is incorrect.")
    }

    func testGetFullURLForPopular() {
        let expectedURL = "https://api.themoviedb.org/3/movie/popular"
        
        let resultURL = urlManager.getFullURL(details: "popular", movieID: 0)
        
        XCTAssertEqual(resultURL, expectedURL, "The generated URL for popular movies is incorrect.")
    }

    func testGetFullURLForMovieDetails() {
        let movieID = 12345
        let expectedURL = "https://api.themoviedb.org/3/movie/\(movieID)"
        
        let resultURL = urlManager.getFullURL(details: "movie", movieID: movieID)
        
        XCTAssertEqual(resultURL, expectedURL, "The generated URL for movie details is incorrect.")
    }

    func testGetFullURLWithInvalidDetails() {
        let expectedURL = "https://api.themoviedb.org/3/movie/upcoming"
        
        let resultURL = urlManager.getFullURL(details: "invalid_detail", movieID: 0)
        
        XCTAssertEqual(resultURL, expectedURL, "The generated URL for an invalid detail should default to upcoming movies.")
    }
}
