//
//  NowPlayingViewModel.swift
//  Banquemisr.challenge05
//
//  Created by ios on 27/09/2024.
//

import Foundation
import Combine
import UIKit

class MovieListViewModel: MovieViewModelProtocol {
    private var cancellables = Set<AnyCancellable>()
    private var networkManager: NetworkManagerProtocol?
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
    
    func fetchNowPlayingMovies() {
        networkManager?.fetch(url: urlManager?.getFullURL(details: endPoint ?? "", movieID: 0) ?? "", type: MoviesResponse.self)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("Successfully fetched movies.")
                case .failure(let error):
                    print("Error fetching movies: \(error.localizedDescription)")
                }
            }, receiveValue: { [weak self] moviesResponse in
                guard let result = moviesResponse.results else{
                    print("Error in response \(URLError(.badServerResponse))")
                    return
                    
                }
                guard let self = self else{return}
                self.movies = result
                PersistenceManager.shared.deleteAllNews(entityName: self.entityName ?? "")
                for movie in result {
                    PersistenceManager.shared.storeMovies(movie, entityName: self.entityName ?? "")
                }
                
            })
            .store(in: &cancellables)
    }
    
    func fetchImage(for movie: Movie) -> AnyPublisher<UIImage?, Never> {
        let baseUrl = "https://image.tmdb.org/t/p/w500/"
        
        guard let imageURL = URL(string: "\(baseUrl)\(movie.posterPath ?? "")")  else {
                return Just(nil).eraseToAnyPublisher()
            }
            
            return URLSession.shared.dataTaskPublisher(for: imageURL)
                .map { data, _ in
                    UIImage(data: data)
                }
                .catch { _ in Just(nil) }  // In case of an error, return nil
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
    
    func loadDatafromCoreData() {
        let storedMovies = PersistenceManager.shared.getMovies(entityName: entityName ?? "")
            for movie in storedMovies {
                var moviee = Movie(backdropPath: "", id: 0, originalLanguage: "", overview: "", posterPath: "", releaseDate: "", title: "", voteAverage: 0, voteCount: 0)
                moviee.backdropPath = movie.value(forKey: "backdropPath") as? String
                moviee.originalLanguage = movie.value(forKey: "originalLanguage") as? String
                moviee.id = movie.value(forKey: "id") as? Int
                moviee.posterPath = movie.value(forKey: "posterPath") as? String
                moviee.title = movie.value(forKey: "title") as? String
                moviee.releaseDate = movie.value(forKey: "releaseDate") as? String
                moviee.voteAverage = movie.value(forKey: "voteAverage") as? Double
                moviee.voteCount = movie.value(forKey: "voteCount") as? Int
                moviee.overview = movie.value(forKey: "overview") as? String
                self.movies.append(moviee)
            }
        }
     
}

