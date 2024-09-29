//
//  MoviesCell.swift
//  Banquemisr.challenge05
//
//  Created by ios on 27/09/2024.
//

import UIKit
import Combine
import Network

class MoviesCell: UITableViewCell {

   
    private var cancellable: AnyCancellable?
    let monitor = NWPathMonitor()
    var isConnected: Bool = false
    @IBOutlet weak var movieLanguageLbl: UILabel!
    @IBOutlet weak var movieDateLbl: UILabel!
    @IBOutlet weak var movieNameLbl: UILabel!
    @IBOutlet weak var movieImg: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(with movie: Movie) {
            movieNameLbl.text = movie.title
            movieLanguageLbl.text = movie.originalLanguage
            movieDateLbl.text = movie.releaseDate
            
        monitor.pathUpdateHandler = { path in
                self.isConnected = (path.status == .satisfied)
                    DispatchQueue.main.async {
                        if self.isConnected {
                            //  is online
                            self.cancellable = FetchingImages.fetchImage(for: movie)
                                .sink { [weak self] image in
                                    guard let image = image else{return}
                                    self?.movieImg.image = UIImage(data: image)  ?? UIImage(named: "placeholder")
                                }
                        } else {
                            //  is offline
                            
                            guard let posterPath = movie.posterPath else {
                                print("No posterPath found in Core Data")
                                return
                            }
                                
                            if let data = Data(base64Encoded: posterPath, options: .ignoreUnknownCharacters) {
                                self.movieImg.image = UIImage(data: data)
                            } else {
                                print("Failed to decode image from Core Data")
                            }
                            }
                        }
                        }
                
                let queue = DispatchQueue(label: "NetworkMonitor")
                monitor.start(queue: queue)
            // Fetch and assign the image
            
        }
    
}
