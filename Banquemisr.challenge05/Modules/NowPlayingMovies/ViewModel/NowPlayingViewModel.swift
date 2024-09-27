//
//  NowPlayingViewModel.swift
//  Banquemisr.challenge05
//
//  Created by ios on 27/09/2024.
//

import Foundation
import Combine

class nowPlayingViewModel{
    private var cancellables = Set<AnyCancellable>()
    private var networkManager : NetworkManagerProtocol?
    var urlManager : URLManagerProtocol?

    init() {
       
        self.networkManager = NetworkManager()
        self.urlManager = URLManager()
    }
    func fetchNowPlayingMovies() {
        let url = "https://api.themoviedb.org/3/movie/now_playing"
        
        networkManager?.fetch(url: urlManager?.getUrl(for: .nowPlaying) ?? "", type: MoviesResponse.self)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("Successfully fetched movies.")
                case .failure(let error):
                    print("Error fetching movies: \(error.localizedDescription)")
                }
            }, receiveValue: { moviesResponse in
                print("Received movies: \(moviesResponse)")
            })
            .store(in: &cancellables) // Ensure we store the cancellable to keep the subscription alive
    }
}
