//
//  NowPlayingViewModel.swift
//  Banquemisr.challenge05
//
//  Created by ios on 27/09/2024.
//

import Foundation
import Combine
import UIKit

class NowPlayingViewModel {
    private var cancellables = Set<AnyCancellable>()
    private var networkManager: NetworkManagerProtocol?
    var urlManager: URLManagerProtocol?
    
    @Published var movies: [Movie] = []
    
    init() {
        self.networkManager = NetworkManager()
        self.urlManager = URLManager()
    }
    
    func fetchNowPlayingMovies() {
        networkManager?.fetch(url: urlManager?.getUrl(for: .nowPlaying) ?? "", type: MoviesResponse.self)
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
                self?.movies = result
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
}
