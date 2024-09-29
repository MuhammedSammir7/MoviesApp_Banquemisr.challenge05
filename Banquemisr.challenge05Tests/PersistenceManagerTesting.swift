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
        
        // Initialize the PersistenceManager with the mock context
        persistenceManager = PersistenceManager.shared
        persistenceManager.managedContext = mockManagedObjectContext
    }
    
    override func tearDownWithError() throws {
        persistenceManager = nil
        mockManagedObjectContext = nil
    }
    
    // Test storing movies
    func testStoreMovies() {
        let movies = [
            Movie(id: 1, backdropPath: "/path1", originalLanguage: "en", overview: "Overview1", releaseDate: "2023-01-01", title: "Title1", voteAverage: 7.5, voteCount: 100),
            Movie(id: 2, backdropPath: "/path2", originalLanguage: "fr", overview: "Overview2", releaseDate: "2023-02-01", title: "Title2", voteAverage: 8.0, voteCount: 200)
        ]
        
        persistenceManager.storeMovies(movies, entityName: "NowPlayingMovies")
        
        // Fetch the stored movies to verify
        let storedMovies = persistenceManager.getMovies(entityName: "NowPlayingMovies")
        XCTAssertEqual(storedMovies.count, 2, "Two movies should have been stored.")
    }
    
    // Test retrieving movies
    func testGetMovies() {
        let movie = NSEntityDescription.insertNewObject(forEntityName: "NowPlayingMovies", into: mockManagedObjectContext)
        movie.setValue("Test Movie", forKey: "title")
        
        let storedMovies = persistenceManager.getMovies(entityName: "NowPlayingMovies")
        XCTAssertEqual(storedMovies.count, 1, "One movie should be fetched.")
    }
    
    // Test deleting all movies
    func testDeleteAllMovies() {
        // Insert a movie into the context
        let movie = NSEntityDescription.insertNewObject(forEntityName: "NowPlayingMovies", into: mockManagedObjectContext)
        movie.setValue("Test Movie", forKey: "title")
        
        // Call the delete method
        persistenceManager.deleteAllMovies(entityName: "MyMovieDetails")
        
        let storedMovies = persistenceManager.getMovies(entityName: "MyMovieDetails")
        XCTAssertEqual(storedMovies.count, 0, "All movies should have been deleted.")
    }
    
    // Test storing specific movie details
    func testStoreSpecificMovie() {
        let movieDetails = MovieDetailsResponse(backdropPath: "/backdrop", genres: [Genre( name: "Action")], id: 1, originalLanguage: "en", originalTitle: "Test Title", overview: "Test overview", posterPath: "/poster", releaseDate: "2023-01-01", runtime: 120, title: "Test Movie", voteAverage: 8.5, voteCount: 1000)
        
        persistenceManager.storeSpecificMovie(currentMovie: movieDetails)
        
        // Fetch to verify
        let storedMovies = persistenceManager.getMovies(entityName: "MyMovieDetails")
        XCTAssertEqual(storedMovies.count, 1, "One specific movie should have been stored.")
    }
}
