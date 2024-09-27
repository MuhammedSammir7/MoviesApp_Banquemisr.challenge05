//
//  NowPlayingMoviesVC.swift
//  Banquemisr.challenge05
//
//  Created by ios on 27/09/2024.
//

import UIKit

class NowPlayingMoviesVC: UIViewController {

    @IBOutlet weak var nowPlayingTableView: UITableView!
    var vm : nowPlayingViewModel?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        vm = nowPlayingViewModel()
        vm?.fetchNowPlayingMovies()
    }
    

    
}
