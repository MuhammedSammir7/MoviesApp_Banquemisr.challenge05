//
//  PersistenceManager.swift
//  Banquemisr.challenge05Tests
//
//  Created by ios on 29/09/2024.
//

import XCTest
import CoreData
@testable import Banquemisr_challenge05

class PersistenceManagerTests: XCTestCase {

    var persistenceManager: PersistenceManager!
    var mockManagedObjectContext: NSManagedObjectContext!

    override func setUpWithError() throws {
        let managedObjectModel = NSManagedObjectModel.mergedModel(from: [Bundle.main])!
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)

        try persistentStoreCoordinator.addPersistentStore(
            ofType: NSInMemoryStoreType,
            configurationName: nil,
            at: nil,
            options: nil
        )

        mockManagedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        mockManagedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator

        persistenceManager = PersistenceManager.shared
        persistenceManager.managedContext = mockManagedObjectContext
    }

    override func tearDownWithError() throws {
        persistenceManager = nil
        mockManagedObjectContext = nil
    }

    // Test storing an empty list of movies
    func testStoreEmptyMovies() {
        let emptyMovies: [Movie] = []
        persistenceManager.storeMovies(emptyMovies, entityName: "NowPlayingMovies")

        let storedMovies = persistenceManager.getMovies(entityName: "NowPlayingMovies")
        XCTAssertEqual(storedMovies.count, 0, "No movies should have been stored.")
    }

    // Test for storing duplicate movies
    func testStoreMovies() {
        let movies = [
            Movie(id: 1, backdropPath: "/path1", originalLanguage: "en", overview: "Overview1", releaseDate: "2023-01-01", title: "Title1", voteAverage: 7.5, voteCount: 100)
            
        ]

        persistenceManager.storeMovies(movies, entityName: "NowPlayingMovies")
        
        let storedMovies = persistenceManager.getMovies(entityName: "NowPlayingMovies")
        XCTAssertEqual(storedMovies.count, 1, "movies should be stored.")
    }

    func testGetMoviesFromEmptyDatabase() {
        let storedMovies = persistenceManager.getMovies(entityName: "NowPlayingMovies")
        XCTAssertEqual(storedMovies.count, 0, "No movies should be fetched from an empty database.")
    }


   
    // Test fetching specific movies
    func testStoreSpecificMovie() {
        let movieDetails = MovieDetailsResponse(
            backdropPath: "/backdrop",
            genres: [Genre(name: "Action")],
            id: 1,
            originalLanguage: "en",
            originalTitle: "Test Title",
            overview: "Test overview",
            posterPath: "/poster",
            releaseDate: "2023-01-01",
            runtime: 120,
            title: "Test Movie",
            voteAverage: 8.5,
            voteCount: 1000
        )
        
        persistenceManager.storeSpecificMovie(currentMovie: movieDetails)
        
        let storedMovies = persistenceManager.getMovies(entityName: "MyMovieDetails")
        XCTAssertEqual(storedMovies.count, 1, "One specific movie should have been stored.")
    }
}
