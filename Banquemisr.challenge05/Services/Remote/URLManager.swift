//
//  URLManager.swift
//  Banquemisr.challenge05
//
//  Created by ios on 27/09/2024.
//

import Foundation

class URLManager: URLManagerProtocol {
  
        func getPath(for endpoint: EndPoint) -> String {
            switch endpoint {
            case .popular:
                return "/popular"
            case .upComing:
                return "/upcoming"
            case .nowPlaying:
                return "/now_playing"
            case .details(let movie_id):
                return "/\(movie_id)"
            case .base:
                return ""
            }
    }
    func getUrl(for endPoint: EndPoint)-> String{
        let path = getPath(for: endPoint)
        let baseUrl = "https://api.themoviedb.org/3/movie"
        
        return "\(baseUrl)\(path)"
    }
}
enum EndPoint: Any {
    case popular
    case upComing
    case nowPlaying
    case details(movie_id: Int)
    case base

  
}
