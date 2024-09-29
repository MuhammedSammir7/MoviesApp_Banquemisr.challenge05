//
//  MovieDetailsViewModel.swift
//  Banquemisr.challenge05
//
//  Created by ios on 27/09/2024.
//

import Foundation
import Combine
import UIKit

class MovieDetailsViewModel{
    private var cancellables = Set<AnyCancellable>()
    private var networkManager: NetworkManagerProtocol?
    var urlManager: URLManagerProtocol?
    var movieId : Int?
    
    @Published var movie: MovieDetailsResponse?
    
    init() {
        self.networkManager = NetworkManager()
        self.urlManager = URLManager()
    }
    func fetchMovieDetails(){
        networkManager?.fetch(url: urlManager?.getFullURL(details: "movie", movieID: movieId ?? 0) ?? "", type: MovieDetailsResponse.self).sink(receiveCompletion: { completion in
            switch completion {
            case .finished:
                print("Successfully fetched movies.")
            case .failure(let error):
                print("Error fetching movies: \(error.localizedDescription)")
            }
        }, receiveValue: { [weak self] moviesResponse in
            print(moviesResponse)
            
            self?.movie = moviesResponse
            PersistenceManager.shared.storeSpecificMovie(currentMovie: moviesResponse)
        })
        .store(in: &cancellables)
    }

    func fetchPosterImage() -> AnyPublisher<UIImage?, Never> {
        let baseUrl = "https://image.tmdb.org/t/p/w500/"
        
        guard let imagePosterURL = URL(string: "\(baseUrl)\(movie?.posterPath ?? "")")  else {
                return Just(nil).eraseToAnyPublisher()
            }

        print(imagePosterURL)
        print(movie?.posterPath ?? "no img")
            return URLSession.shared.dataTaskPublisher(for: imagePosterURL)
                .map { data, _ in
                    UIImage(data: data)
                }
                .catch { _ in Just(nil) }
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
    func loadDatafromCoreData() {
            PersistenceManager.shared.getMovie(completion: { storedMovies in
                guard let storedMovies = storedMovies else {
                    print("Failed to fetch movies from Core Data")
                    return
                }

                print("Loading \(storedMovies.count) movies from Core Data")

                for movieData in storedMovies {
                    if let storedMovieId = movieData.value(forKey: "id") as? Int, storedMovieId == self.movieId {
                        var movie = MovieDetailsResponse()
                        movie.backdropPath = movieData.value(forKey: "backdropPath") as? String
                        movie.originalLanguage = movieData.value(forKey: "originalLanguage") as? String
                        movie.overview = movieData.value(forKey: "overview") as? String
                        movie.posterPath = movieData.value(forKey: "posterPath") as? String
                        movie.releaseDate = movieData.value(forKey: "releaseDate") as? String
                        movie.originalTitle = movieData.value(forKey: "originalTitle") as? String
                        movie.voteCount = movieData.value(forKey: "voteCount") as? Int
                        movie.voteAverage = movieData.value(forKey: "voteAverage") as? Double
                        movie.runtime = movieData.value(forKey: "runtime") as? Int
                        
                        if let genresString = movieData.value(forKey: "genres") as? String {
                            let genreNames = genresString.components(separatedBy: ", ")
                            movie.genres = genreNames.map { Genre(name: $0) }
                        }

                        self.movie = movie
                        print("Loaded movie from Core Data: \(movie)")
                        break
                    }
                }
            })
        }

    
    func fetchBackgroundImg() -> AnyPublisher<UIImage?, Never> {
        let baseUrl = "https://image.tmdb.org/t/p/w500/"
        
            guard let imageBackgroundURL = URL(string: "\(baseUrl)\(movie?.backdropPath ?? "")")  else {
                    return Just(nil).eraseToAnyPublisher()
                }
        
            return URLSession.shared.dataTaskPublisher(for: imageBackgroundURL)
                .map { data, _ in
                    UIImage(data: data)
                }
                .catch { _ in Just(nil) }
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
    
}
