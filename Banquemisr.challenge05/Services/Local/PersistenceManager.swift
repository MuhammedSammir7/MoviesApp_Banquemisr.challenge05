//
//  PersistenceManager.swift
//  Banquemisr.challenge05
//
//  Created by ios on 28/09/2024.
//

import Foundation
import CoreData
import UIKit
import Combine

class PersistenceManager {
    private var cancellables = Set<AnyCancellable>()
    private var cancellable: AnyCancellable?
    var managedContext: NSManagedObjectContext!
    var storedMovies : [NSManagedObject]?
    static let shared = PersistenceManager()
    
    private init(){
        managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    func storeMovies(_ movies: [Movie], entityName: String) {
        guard let entity = NSEntityDescription.entity(forEntityName: entityName, in: managedContext) else {
            print("Failed to find entity \(entityName)")
            return
        }
        
        // Use DispatchGroup to manage asynchronous tasks
        let dispatchGroup = DispatchGroup()
        
        for movie in movies {
            dispatchGroup.enter() // Enter the group for each movie
            let moviee = NSManagedObject(entity: entity, insertInto: managedContext)
            
            moviee.setValue(movie.backdropPath, forKey: "backdropPath")
            moviee.setValue(movie.id, forKey: "id")
            moviee.setValue(movie.originalLanguage, forKey: "originalLanguage")
            moviee.setValue(movie.overview, forKey: "overview")
            moviee.setValue(movie.releaseDate, forKey: "releaseDate")
            moviee.setValue(movie.title, forKey: "title")
            moviee.setValue(movie.voteAverage, forKey: "voteAverage")
            moviee.setValue(movie.voteCount, forKey: "voteCount")

            let cancellable = FetchingImages.fetchImage(for: movie)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        dispatchGroup.leave()
                    case .failure(let error):
                        print("Error fetching image for movie: \(movie.title ?? "Unknown Title"): \(error)")
                        dispatchGroup.leave()
                    }
                }, receiveValue: { image in
                    guard let image = image else {
                        return
                    }
                    
                    let base64String = image.base64EncodedString(options: .lineLength64Characters)
                    moviee.setValue(base64String, forKey: "posterPath")
                    
                })
            
            
            self.cancellables.insert(cancellable)
        }
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            do {
                try self?.managedContext.save()
            } catch let error as NSError {
                print("Error saving movies to Core Data: \(error), \(error.userInfo)")
            }
        }
    }

    
    func getMovies(entityName : String) -> [NSManagedObject] {
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "\(entityName)")
            do {
                storedMovies = try managedContext.fetch(fetchRequest)
                if storedMovies?.count == 0 {
                    print("Not data to present")
                }
            } catch let error {
                print("Can't Fetch")
                print(error.localizedDescription)
            }
            return storedMovies ?? []
        }
    
    func deleteAllMovies(entityName : String){
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "\(entityName)")
        do {
            let result = try managedContext.fetch (fetchRequest) as! [NSManagedObject]
            for item in result {
                managedContext.delete(item)
            }
            try managedContext.save()
        }
        catch{
            print ("Error in deleting \(error)")
        }
    }
    
    func storeSpecificMovie(currentMovie: MovieDetailsResponse) {
            guard let entity = NSEntityDescription.entity(forEntityName: "MyMovieDetails", in: managedContext) else { return }
            let movie = NSManagedObject(entity: entity, insertInto: managedContext)
            
            // Set basic movie properties
        movie.setValue(currentMovie.id, forKey: "id")
        movie.setValue(currentMovie.backdropPath, forKey: "backdropPath")
        movie.setValue(currentMovie.originalLanguage, forKey: "originalLanguage")
        movie.setValue(currentMovie.overview, forKey: "overview")
        movie.setValue(currentMovie.posterPath, forKey: "posterPath")
        movie.setValue(currentMovie.releaseDate, forKey: "releaseDate")
        movie.setValue(currentMovie.originalTitle, forKey: "originalTitle")
        movie.setValue(currentMovie.voteAverage, forKey: "voteAverage")
        movie.setValue(currentMovie.runtime, forKey: "runtime")
        movie.setValue(currentMovie.voteCount, forKey: "voteCount")
        movie.setValue(currentMovie.title, forKey: "title")
            
            let genreNames = currentMovie.genres?.compactMap { $0.name }.joined(separator: ", ") ?? ""
            movie.setValue(genreNames, forKey: "genres") 
            
            do {
                try managedContext.save()
                print("Movie saved successfully!")
            } catch let error {
                print("Failed to save movie!")
                print(error.localizedDescription)
            }
        }

    func getMovie(completion: @escaping ([NSManagedObject]?) -> Void) {
            
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "MyMovieDetails")
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.propertiesToFetch = ["id", "backdropPath", "originalLanguage", "overview", "posterPath", "releaseDate", "originalTitle", "voteAverage", "runtime", "genres"]
        
        do {
            let storedMovies = try managedContext.fetch(fetchRequest)
            if storedMovies.isEmpty {
                print("No data found in Core Data")
            }
            completion(storedMovies)
        } catch let error {
            print("Failed to fetch data from Core Data")
            print(error.localizedDescription)
            completion(nil)
        }
        
    }

}
