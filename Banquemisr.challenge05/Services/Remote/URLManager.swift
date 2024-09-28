//
//  URLManager.swift
//  Banquemisr.challenge05
//
//  Created by ios on 27/09/2024.
//

import Foundation

class URLManager: URLManagerProtocol {
        
    enum endpoints : String{
        case upcomming = "upcoming"
        case nowplaying = "now_playing"
        case popular = "popular"
    }
    
    func getFullURL(details: String , movieID : Int = 0) -> String? {
         let base = "https://api.themoviedb.org/3/movie/"
        switch details {
        case endpoints.upcomming.rawValue:
            return base + endpoints.upcomming.rawValue
        case endpoints.popular.rawValue:
            return base + endpoints.popular.rawValue
        case endpoints.nowplaying.rawValue:
            return base + endpoints.nowplaying.rawValue
        case "movie":
            return base + String(movieID)
        default:
            return base + endpoints.upcomming.rawValue
        }
        
    }
}
