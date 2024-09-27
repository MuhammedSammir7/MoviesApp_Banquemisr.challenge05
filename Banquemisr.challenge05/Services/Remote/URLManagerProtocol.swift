//
//  URLManagerProtocol.swift
//  Banquemisr.challenge05
//
//  Created by ios on 27/09/2024.
//

import Foundation

protocol URLManagerProtocol {
    func getPath(for endpoint: EndPoint) -> String
    func getUrl(for endPoint: EndPoint)-> String
}
