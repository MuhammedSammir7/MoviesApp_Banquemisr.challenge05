//
//  FetchingImages.swift
//  Banquemisr.challenge05
//
//  Created by ios on 29/09/2024.
//

import Foundation
import Combine
import UIKit

class FetchingImages {
    static func fetchImage(for movie: Movie) -> AnyPublisher<Data?, Never> {
        let baseUrl = "https://image.tmdb.org/t/p/w500/"
        
        guard let imageURL = URL(string: "\(baseUrl)\(movie.posterPath ?? "")")  else {
                return Just(nil).eraseToAnyPublisher()
            }
            
            return URLSession.shared.dataTaskPublisher(for: imageURL)
                .map { data, _ in
                    data
                }
                .catch { _ in Just(nil) }  
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
}
