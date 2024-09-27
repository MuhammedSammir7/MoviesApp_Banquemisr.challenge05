//
//  MoviesCell.swift
//  Banquemisr.challenge05
//
//  Created by ios on 27/09/2024.
//

import UIKit

class MoviesCell: UITableViewCell {

   
    @IBOutlet weak var movieGenreLbl: UILabel!
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
    
}
