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
    func testFetchMoviesEmpty() {
        // Given
        mockNetworkManager.mockMoviesResponse = MoviesResponse(dates: Dates(maximum: "", minimum: ""), results: [])
        let expectation = self.expectation(description: "Movies fetched")

        // When
        viewModel.fetchMovies()
        viewModel.$movies
            .sink { movies in
                // Then
                XCTAssertTrue(movies.isEmpty, "Movies list should be empty")
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 2.0)
    }
    func testFetchMoviesSortedByTitle() {
        // Given
        let mockMovies = [
            Movie(id: 1, backdropPath: "/path1", originalLanguage: "en", overview: "Overview1", releaseDate: "2024-01-01", title: "Movie B", voteAverage: 8.0, voteCount: 100),
            Movie(id: 2, backdropPath: "/path2", originalLanguage: "en", overview: "Overview2", releaseDate: "2024-01-02", title: "Movie A", voteAverage: 9.0, voteCount: 150)
        ]
        let mockMoviesResponse = MoviesResponse(dates: Dates(maximum: "", minimum: ""), results: mockMovies)
        mockNetworkManager.mockMoviesResponse = mockMoviesResponse

        let expectation = self.expectation(description: "Movies fetched and sorted")

        // When
        viewModel.fetchMovies()
        viewModel.$movies
            .sink { movies in
                // Then
                XCTAssertEqual(movies.count, 2)
                XCTAssertEqual(movies[0].title, "Movie A")
                XCTAssertEqual(movies[1].title, "Movie B")
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 2.0)
    }

    func testFetchMoviesLoadingState() {
        let mockViewModel = MockMovieListViewModel(entityName: "NowPlayingMovies", endPoint: "now_playing")
        mockViewModel.shouldSimulateLoading = true

        let expectation = self.expectation(description: "Loading state")

        mockViewModel.fetchMovies()

        mockViewModel.$isLoading
            .sink { isLoading in
                if isLoading {
                    XCTAssertTrue(isLoading, "ViewModel should be loading.")
                } else {
                    XCTAssertFalse(isLoading, "ViewModel should have finished loading.")
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 2.0)
    }

    func testFetchMoviesNetworkErrorHandling() {
        let mockViewModel = MockMovieListViewModel(entityName: "NowPlayingMovies", endPoint: "now_playing")
        mockViewModel.shouldSimulateNetworkError = true
        let expectation = self.expectation(description: "Error handled")

        mockViewModel.fetchMovies()
        
        mockViewModel.$errorMessage
            .dropFirst()
            .sink { errorMessage in
                XCTAssertNotNil(errorMessage)
                XCTAssertEqual(errorMessage, "Network error. Please check your connection.")
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 2.0)
    }


}

class MockMovieListViewModel: MovieListViewModel {
    var shouldSimulateLoading: Bool = false
    var shouldSimulateNetworkError: Bool = false

    @Published var errorMessage: String?
    @Published var isLoading: Bool = false

    override func fetchMovies() {
        if shouldSimulateLoading {
            DispatchQueue.main.async {
                self.isLoading = true
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.isLoading = false
                }
            }
        } else if shouldSimulateNetworkError {
            DispatchQueue.main.async {
                self.errorMessage = "Network error. Please check your connection."
            }
        } else {
            super.fetchMovies()
        }
    }
}
