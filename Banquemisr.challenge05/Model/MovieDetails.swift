//
//  MovieDetails.swift
//  Banquemisr.challenge05
//
//  Created by ios on 27/09/2024.
//

import Foundation

struct MovieDetailsResponse: Codable {
    var backdropPath: String?
    var genres: [Genre]?
    var id: Int?
    var originalLanguage: String?
    var originalTitle : String?
    var overview: String?
    var posterPath: String?
    var releaseDate: String?
    var runtime: Int?
    var title: String?
    var voteAverage: Double?
    var voteCount: Int?
    
    enum CodingKeys: String,CodingKey {
        case backdropPath = "backdrop_path"
        case genres
        case id
        case originalLanguage = "original_language"
        case originalTitle = "original_title"
        case overview
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case runtime
        case title
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }
    
}
struct Genre: Codable {
    var name: String?
}
