//
//  NowPlayingMoviesVC.swift
//  Banquemisr.challenge05
//
//  Created by ios on 27/09/2024.
//

import UIKit
import Combine
import Network

class MovieListVC: UIViewController {

    @IBOutlet weak var loadingImg: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var nowPlayingTableView: UITableView!

    var vm : MovieListViewModel?
    var indicator: UIActivityIndicatorView?
    let monitor = NWPathMonitor()
    var isConnected: Bool = false
    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        loadingImg.isHidden = false
        nowPlayingTableView.isHidden = true
        setupTabBar()
        nowPlayingTableView.delegate = self
        nowPlayingTableView.dataSource = self
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

        
        nowPlayingTableView.register(UINib(nibName: "MoviesCell", bundle: nil), forCellReuseIdentifier: "MoviesCell")
        
    }
    func fetchDataFromAPI(){
        vm?.fetchMovies()
        vm?.$movies.sink { [weak self] _ in
                    DispatchQueue.main.async {
                        self?.nowPlayingTableView.reloadData()
                        if self?.vm?.movies.count != 0 {
                            self?.indicator?.stopAnimating()
                            self?.loadingImg.isHidden = true
                            self?.nowPlayingTableView.isHidden = false
                        }
                    }
                }.store(in: &cancellables)
    }
    func fetchDataFromCoreData(){
        vm?.loadDatafromCoreData()
        vm?.$movies.sink { [weak self] _ in
            DispatchQueue.main.async {
                self?.nowPlayingTableView.reloadData()
                if self?.vm?.movies.count != 0 {
                    self?.indicator?.stopAnimating()
                    self?.loadingImg.isHidden = true
                    self?.nowPlayingTableView.isHidden = false
                }
            }
        }.store(in: &cancellables)
    }
    func setupTabBar(){
        if let items = self.tabBarController?.tabBar.items {
            items[0].title = "NowPlaying"
            items[0].image = UIImage(named: "now")?.withRenderingMode(.alwaysOriginal)
            items[0].imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: -4, right: 0)

            items[1].title = "UpComing"
            items[1].image = UIImage(named: "upcoming")?.withRenderingMode(.alwaysOriginal)
            items[1].imageInsets = UIEdgeInsets(top: 2, left: 0, bottom: -2, right: 0)

            items[2].title = "Popular"
            items[2].image = UIImage(named: "popular")?.withRenderingMode(.alwaysOriginal)
            items[2].imageInsets = UIEdgeInsets(top: 2, left: 0, bottom: -2, right: 0)
        }
        
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        if let tabBarColor = UIColor(hex: "#313B46") {
            appearance.backgroundColor = tabBarColor
        }
        self.tabBarController?.tabBar.tintColor = UIColor.white
        self.tabBarController?.tabBar.standardAppearance = appearance
        self.tabBarController?.tabBar.scrollEdgeAppearance = appearance


        switch self.tabBarController?.tabBar.selectedItem?.title {
        case "UpComing":
            titleLbl.text = "UpComing"
            vm = MovieListViewModel(entityName: "UpComigMovies", endPoint: "upcoming")
        case "Popular":
            titleLbl.text = "Popular"
            vm = MovieListViewModel(entityName: "Popular", endPoint: "popular")
        default:
            titleLbl.text = "NowPlaying"
            vm = MovieListViewModel(entityName: "NowPlayingMovies", endPoint: "now_playing")
        }
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
extension MovieListVC : UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        vm?.movies.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = nowPlayingTableView.dequeueReusableCell(withIdentifier: "MoviesCell") as? MoviesCell {
            
            if let movieData = vm?.movies[indexPath.row] {
                cell.configure(with: movieData)
            }
            
            return cell
            
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "MovieDetailsStoryboard", bundle: nil)
        if let movieDetailsVc = storyboard.instantiateViewController(withIdentifier: "MovieDetailsVC") as? MovieDetailsVC {
            guard let movieData = vm?.movies[indexPath.row] else {return}
            movieDetailsVc.viewModel.movieId = movieData.id
            movieDetailsVc.modalTransitionStyle = .crossDissolve
            movieDetailsVc.modalPresentationStyle = .fullScreen
            self.present(movieDetailsVc, animated: true)
        }
    }
}

