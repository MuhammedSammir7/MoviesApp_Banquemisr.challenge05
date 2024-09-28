//
//  URLManagerProtocol.swift
//  Banquemisr.challenge05
//
//  Created by ios on 27/09/2024.
//

import Foundation

protocol URLManagerProtocol {
    func getFullURL(details: String , movieID : Int) -> String?
}
