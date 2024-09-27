//
//  MovieDetailsVC.swift
//  Banquemisr.challenge05
//
//  Created by ios on 27/09/2024.
//

import UIKit
import Combine

class MovieDetailsVC: UIViewController {

    @IBOutlet weak var voteCountLbl: UILabel!
    @IBOutlet weak var movieRatingLbl: UILabel!
    @IBOutlet weak var overViewTxt: UITextView!
    @IBOutlet weak var movieLanguageLbl: UILabel!
    @IBOutlet weak var genreLbl: UILabel!
    @IBOutlet weak var relasedDateLbl: UILabel!
    @IBOutlet weak var movieNameLbl: UILabel!
    @IBOutlet weak var moviePosterImg: UIImageView!
    @IBOutlet weak var backgroundImg: UIImageView!
    
    var indicator: UIActivityIndicatorView?
    var viewModel = MovieDetailsViewModel()
    private var cancellables = Set<AnyCancellable>()
    private var cancellable: AnyCancellable?
    private var cancellabl: AnyCancellable?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupIndecator()
        viewModel.fetchMovieDetails()
        viewModel.$movie.sink { [weak self] _ in
                    DispatchQueue.main.async {
                        guard let self = self else{return}
                        guard let movieData = self.viewModel.movie else {
                            print("Movie data not available.")
                            return
                        }
                        self.movieNameLbl.text = movieData.title
                        self.movieRatingLbl.text = "\(movieData.voteAverage ?? 0)"
                        self.relasedDateLbl.text = movieData.releaseDate
                        self.overViewTxt.text = movieData.overview
                        self.voteCountLbl.text = "\(movieData.voteCount ?? 0)"
                        self.movieLanguageLbl.text = movieData.originalLanguage
                        if movieData.genres?.count ?? 0 > 1{
                            self.genreLbl.text = "\(movieData.genres?[0].name ?? ""),\(movieData.genres?[1].name ?? "")"}
                        else{
                            
                                self.genreLbl.text = "\(movieData.genres?[0].name ?? "")"
                        }
                        self.cancellabl = self.viewModel.fetchPosterImage()
                            .sink { [weak self] image in
                                self?.moviePosterImg.image = image ?? UIImage(named: "img2")
                            }
                        self.cancellable = self.viewModel.fetchBackgroundImg()
                            .sink { [weak self] image in
                                self?.backgroundImg.image = image ?? UIImage(named: "img")
                            }
                        self.indicator?.stopAnimating()
                    }
                }.store(in: &cancellables)
    }
    
    @IBAction func backBtn(_ sender: Any) {
        self.dismiss(animated: true)
    }
    func setupIndecator(){
        indicator = UIActivityIndicatorView(style: .large)
        guard let indicator = indicator else{return}
        indicator.center = self.view.center
        indicator.startAnimating()
        self.view.addSubview(indicator)
        indicator.startAnimating()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
