//
//  MovieDetailsVC.swift
//  Banquemisr.challenge05
//
//  Created by ios on 27/09/2024.
//

import UIKit
import Combine
import Network
class MovieDetailsVC: UIViewController {

    @IBOutlet weak var durationLbl: UILabel!
    @IBOutlet weak var voteCountLbl: UILabel!
    @IBOutlet weak var movieRatingLbl: UILabel!
    @IBOutlet weak var overViewTxt: UITextView!
    @IBOutlet weak var movieLanguageLbl: UILabel!
    @IBOutlet weak var genreLbl: UILabel!
    @IBOutlet weak var relasedDateLbl: UILabel!
    @IBOutlet weak var movieNameLbl: UILabel!
    @IBOutlet weak var moviePosterImg: UIImageView!
    @IBOutlet weak var backgroundImg: UIImageView!
    
    var imageIndicator: UIImageView?
    var indicator: UIActivityIndicatorView?
    var viewModel = MovieDetailsViewModel()
    private var cancellables = Set<AnyCancellable>()
    private var cancellable: AnyCancellable?
    private var cancellabl: AnyCancellable?
    let monitor = NWPathMonitor()
    var isConnected: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupImageIndicator()
        setupIndecator()
        monitor.pathUpdateHandler = { path in
                self.isConnected = (path.status == .satisfied)
                    DispatchQueue.main.async {
                        if self.isConnected {
                            //  is online
                            self.fetchDataFromAPI()
                        } else {
                            //  is offline
                            self.fetchDataFromCoreData()
                        }
                    }
                }
                
                let queue = DispatchQueue(label: "NetworkMonitor")
                monitor.start(queue: queue)
        
    }
    func fetchDataFromAPI(){
        viewModel.fetchMovieDetails()

        viewModel.$movie.sink { [weak self] movieData in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if let movieData = movieData {
                    
                    self.setUpViewComponents(with: movieData)
                }
            }
        }.store(in: &cancellables)
        
    }
    func fetchDataFromCoreData(){
        viewModel.loadDatafromCoreData()

        viewModel.$movie.sink { [weak self] movieData in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if let movieData = movieData {
                    
                    self.setUpViewComponents(with: movieData)
                } else {
                    
                    self.presentNoDataAlert()
                }
            }
        }.store(in: &cancellables)
        
    }
    func setUpViewComponents(with movieData: MovieDetailsResponse){
        self.movieNameLbl.text = movieData.title
            self.movieRatingLbl.text = "\(movieData.voteAverage ?? 0)"
            self.relasedDateLbl.text = movieData.releaseDate
            self.overViewTxt.text = movieData.overview
            self.voteCountLbl.text = "\(movieData.voteCount ?? 0)"
            self.movieLanguageLbl.text = movieData.originalLanguage
            
            let hours = (movieData.runtime ?? 0) / 60
            let minutes = (movieData.runtime ?? 0) % 60
            self.durationLbl.text = "\(hours) h \(minutes) m"
            
            if let genres = movieData.genres, genres.count > 1 {
                self.genreLbl.text = "\(genres[0].name ?? ""), \(genres[1].name ?? "")"
            } else {
                self.genreLbl.text = "\(movieData.genres?.first?.name ?? "")"
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
            self.imageIndicator?.isHidden = true
        }

    @IBAction func backBtn(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
}
extension MovieDetailsVC {
    func setupImageIndicator() {
        
        imageIndicator = UIImageView(image: UIImage(named: "loading"))
        imageIndicator?.contentMode = .scaleAspectFill
        imageIndicator?.translatesAutoresizingMaskIntoConstraints = false

        if let imageIndicator = imageIndicator {
            self.view.addSubview(imageIndicator)

            NSLayoutConstraint.activate([
                imageIndicator.topAnchor.constraint(equalTo: self.view.topAnchor),
                imageIndicator.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
                imageIndicator.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                imageIndicator.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
            ])

            imageIndicator.isHidden = false
        }
    }
    private func presentNoDataAlert() {
        let alert = UIAlertController(title: "Error", message: "Movie data not found locally, check the internet connection and try again.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.dismiss(animated: true, completion: nil)
        })
        self.present(alert, animated: true, completion: nil)
    }
    func setupIndecator(){
        indicator = UIActivityIndicatorView(style: .large)
        guard let indicator = indicator else{return}
        indicator.center = self.view.center
        indicator.startAnimating()
        self.view.addSubview(indicator)
        indicator.startAnimating()
    }
    
}
