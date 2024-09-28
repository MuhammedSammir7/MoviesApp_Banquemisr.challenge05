//
//  UpComingMoviesVC.swift
//  Banquemisr.challenge05
//
//  Created by ios on 27/09/2024.
//

import UIKit
import Combine
import Network

class UpComingMoviesVC: UIViewController {

    @IBOutlet weak var upComingTableView: UITableView!
    var vm : UpComingMoviesViewModel?
    var indicator: UIActivityIndicatorView?
    private var cancellables = Set<AnyCancellable>()
    let monitor = NWPathMonitor()
    var isConnected: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()

        setupIndecator()
        upComingTableView.delegate = self
        upComingTableView.dataSource = self
        
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
        
        vm = UpComingMoviesViewModel()
       
        upComingTableView.register(UINib(nibName: "MoviesCell", bundle: nil), forCellReuseIdentifier: "MoviesCell")
        
    }
    func fetchDataFromAPI(){
        vm?.fetchUpComingMovies()
        vm?.$movies.sink { [weak self] _ in
                    DispatchQueue.main.async {
                        self?.upComingTableView.reloadData()
                        self?.indicator?.stopAnimating()
                    }
                }.store(in: &cancellables)
    }
    func fetchDataFromCoreData(){
        vm?.loadDatafromCoreData()
        vm?.$movies.sink { [weak self] _ in
            DispatchQueue.main.async {
                self?.upComingTableView.reloadData()
                self?.indicator?.stopAnimating()
            }
        }.store(in: &cancellables)
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

extension UpComingMoviesVC : UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        vm?.movies.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = upComingTableView.dequeueReusableCell(withIdentifier: "MoviesCell") as? MoviesCell {
            
            if let movieData = vm?.movies[indexPath.row] {
                cell.configure(with: movieData, viewModel: vm!)
            }
            
            return cell
            
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "MovieDetailsStoryboard", bundle: nil)
        if let movieDetailsVc = storyboard.instantiateViewController(withIdentifier: "MovieDetailsVC") as? MovieDetailsVC {
            movieDetailsVc.viewModel.movieId = vm?.movies[indexPath.row].id
            movieDetailsVc.modalTransitionStyle = .crossDissolve
            movieDetailsVc.modalPresentationStyle = .fullScreen
            self.present(movieDetailsVc, animated: true)
        }
    }
}

