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
    var MovieNoConnection = Movie()
    
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
