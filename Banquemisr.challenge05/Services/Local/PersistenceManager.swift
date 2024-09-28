//
//  PersistenceManager.swift
//  Banquemisr.challenge05
//
//  Created by ios on 28/09/2024.
//

import Foundation
import CoreData
import UIKit

class PersistenceManager {
    
    var managedContext: NSManagedObjectContext!
    var storedMovies : [NSManagedObject]?
    static let shared = PersistenceManager()
    
    private init(){
        managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    func storeMovies(_ movie : Movie , entityName : String){
        
        var entity = NSEntityDescription.entity(forEntityName: "\(entityName)", in: managedContext)
        let moviee = NSManagedObject(entity: entity!, insertInto: managedContext)
        moviee.setValue(movie.backdropPath, forKey: "backdropPath")
        moviee.setValue(movie.id, forKey: "id")
        moviee.setValue(movie.originalLanguage, forKey: "originalLanguage")
        moviee.setValue(movie.overview, forKey: "overview")
        moviee.setValue(movie.posterPath, forKey: "posterPath")
        moviee.setValue(movie.releaseDate, forKey: "releaseDate")
        moviee.setValue(movie.title, forKey: "title")
        moviee.setValue(movie.voteAverage, forKey: "voteAverage")
        moviee.setValue(movie.voteCount, forKey: "voteCount")
        do{
            try managedContext.save()
            print("\nInserting a league done...\n")
        }catch let error as NSError{
            print("\nerror in adding to favourite: \(error)\n")
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
    
    func deleteAllNews(entityName : String){
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "\(entityName)")
        do {
            let result = try managedContext.fetch (fetchRequest) as! [NSManagedObject]
            for item in result {
                managedContext.delete(item)
            }
            try managedContext.save()
        }
        catch{
            print (error)
        }
    }
}
