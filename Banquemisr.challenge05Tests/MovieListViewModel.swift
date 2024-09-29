//
//  MovieListViewModel.swift
//  Banquemisr.challenge05Tests
//
//  Created by ios on 29/09/2024.
//

import XCTest
import Combine
@testable import Banquemisr_challenge05
import CoreData

class MovieListViewModelTests: XCTestCase {
    var persistenceManager: PersistenceManager!
    var mockManagedObjectContext: NSManagedObjectContext!
    var viewModel: MovieListViewModel!
    var mockNetworkManager: MockNetworkManager!
    var mockURLManager: MockURLManager!
    var mockPersistenceManager: PersistenceManager!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockNetworkManager = MockNetworkManager()
        mockURLManager = MockURLManager()
        viewModel = MovieListViewModel(entityName: "NowPlayingMovies", endPoint: "now_playing")
        viewModel.networkManager = mockNetworkManager
        viewModel.urlManager = mockURLManager
        cancellables = []
        
    }

    override func tearDown() {
        viewModel = nil
        mockNetworkManager = nil
        mockURLManager = nil
        mockPersistenceManager = nil
        cancellables = nil
        super.tearDown()
    }

    override func setUpWithError() throws {
        let modelURL = Bundle.main.url(forResource: "Banquemisr_challenge05", withExtension: "momd")!
        let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL)!
        
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
    
    func testFetchMoviesSuccess() {
        let mockMovies = [
            Movie(id: 1, backdropPath: "/path", originalLanguage: "en", overview: "Overview", releaseDate: "2024-01-01", title: "Mock Movie", voteAverage: 8.0, voteCount: 100)
        ]
        let mockMoviesResponse = MoviesResponse(dates: Dates(maximum: "", minimum: ""), results: mockMovies)
        mockNetworkManager.mockMoviesResponse = mockMoviesResponse

        let expectation = self.expectation(description: "Movies fetched")

        viewModel.fetchMovies()
        viewModel.$movies
            .sink { movies in
                if !movies.isEmpty {
                    XCTAssertEqual(movies.count, 1)
                    XCTAssertEqual(movies.first?.title, "Mock Movie")
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 2.0)
    }

    func testFetchMoviesFailure() {
        mockNetworkManager.mockError = URLError(.notConnectedToInternet)

        let expectation = self.expectation(description: "Movies fetch failed")

        viewModel.fetchMovies()
        viewModel.$movies
            .sink { movies in
                XCTAssertTrue(movies.isEmpty)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 2.0)
    }
}

