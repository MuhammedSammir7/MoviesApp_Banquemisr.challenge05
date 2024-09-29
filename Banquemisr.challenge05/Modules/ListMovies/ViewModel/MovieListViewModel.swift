//
//  NowPlayingViewModel.swift
//  Banquemisr.challenge05
//
//  Created by ios on 27/09/2024.
//

import Foundation
import Combine
import UIKit

class MovieListViewModel {
    var cancellables = Set<AnyCancellable>()
    var networkManager: NetworkManagerProtocol?
    var urlManager: URLManagerProtocol?
    var entityName : String?
    var endPoint : String?
    
    
    @Published var movies: [Movie] = []
    
    init(entityName: String, endPoint : String) {
        self.networkManager = NetworkManager()
        self.urlManager = URLManager()
        self.entityName = entityName
        self.endPoint = endPoint
    }
    
    func fetchMovies() {
        networkManager?.fetch(url: urlManager?.getFullURL(details: endPoint ?? "", movieID: 0) ?? "", type: MoviesResponse.self)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("Successfully fetched movies.")
                case .failure(let error):
                    print("Error fetching movies: \(error.localizedDescription)")
                }
            }, receiveValue: { [weak self] moviesResponse in
                guard let result = moviesResponse.results else {
                    print("Error in response \(URLError(.badServerResponse))")
                    return
                }
                guard let self = self else { return }
                self.movies = result
                PersistenceManager.shared.deleteAllMovies(entityName: self.entityName ?? "")
                PersistenceManager.shared.storeMovies(result, entityName: self.entityName ?? "")
            })
            .store(in: &cancellables)
    }

    
    func loadDatafromCoreData() {
        let storedMovies = PersistenceManager.shared.getMovies(entityName: entityName ?? "")
        self.movies.removeAll() 
        for movie in storedMovies {
            var moviee = Movie(id: 0, backdropPath: "", originalLanguage: "", overview: "", releaseDate: "", title: "", voteAverage: 0, voteCount: 0)

            moviee.backdropPath = movie.value(forKey: "backdropPath") as? String
            moviee.originalLanguage = movie.value(forKey: "originalLanguage") as? String
            moviee.id = movie.value(forKey: "id") as? Int ?? 0
            moviee.posterPath = movie.value(forKey: "posterPath") as? String
            moviee.title = movie.value(forKey: "title") as? String
            moviee.releaseDate = movie.value(forKey: "releaseDate") as? String
            moviee.voteAverage = movie.value(forKey: "voteAverage") as? Double ?? 0.0
            moviee.voteCount = movie.value(forKey: "voteCount") as? Int ?? 0
            moviee.overview = movie.value(forKey: "overview") as? String
            self.movies.append(moviee)
        }

        
    }
    
     
}

