//
//  SettingIndeicator.swift
//  Banquemisr.challenge05
//
//  Created by ios on 28/09/2024.
//

import Foundation
import UIKit

class SettingIndeicator{
    func setupIndecator(_ indicator: UIActivityIndicatorView){
        indicator = UIActivityIndicatorView(style: .large)
        guard let indicator = indicator else{return}
        indicator.center = self.view.center
        indicator.startAnimating()
        self.view.addSubview(indicator)
        indicator.startAnimating()
    }
}
