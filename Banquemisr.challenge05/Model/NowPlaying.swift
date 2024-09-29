//
//  NowPlaying.swift
//  Banquemisr.challenge05
//
//  Created by ios on 27/09/2024.
//


struct MoviesResponse: Codable {
    let dates: Dates?
    let results: [Movie]?
}

struct Dates: Codable {
    let maximum: String?
    let minimum: String?
}

struct Movie: Codable {
    var backdropPath: String?
    var id: Int?
    var originalLanguage: String?
    var overview: String?
    var posterPath: String?
    var releaseDate: String?
    var title: String?
    var voteAverage: Double?
    var voteCount: Int?
    
    enum CodingKeys: String, CodingKey {
        case backdropPath = "backdrop_path"
        case id
        case originalLanguage = "original_language"
        case overview
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case title
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }
    init(id: Int, backdropPath: String, originalLanguage: String, overview: String, releaseDate: String, title: String, voteAverage: Double, voteCount: Int) {
            self.id = id
            self.backdropPath = backdropPath
            self.originalLanguage = originalLanguage
            self.overview = overview
            self.releaseDate = releaseDate
            self.title = title
            self.voteAverage = voteAverage
            self.voteCount = voteCount
        }
}
