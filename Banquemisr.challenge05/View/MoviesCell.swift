//
//  MoviesCell.swift
//  Banquemisr.challenge05
//
//  Created by ios on 27/09/2024.
//

import UIKit
import Combine

class MoviesCell: UITableViewCell {

   
    private var cancellable: AnyCancellable?

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
    
    func configure(with movie: Movie, viewModel: MovieViewModelProtocol) {
            movieNameLbl.text = movie.title
            movieLanguageLbl.text = movie.originalLanguage
            movieDateLbl.text = movie.releaseDate
            
            // Fetch and assign the image
            cancellable = viewModel.fetchImage(for: movie)
                .sink { [weak self] image in
                    self?.movieImg.image = image ?? UIImage(named: "placeholder")
                }
        }
    
}
