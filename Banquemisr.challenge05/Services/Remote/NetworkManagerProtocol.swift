//
//  NetworkManagerProtocol.swift
//  Banquemisr.challenge05
//
//  Created by ios on 27/09/2024.
//

import Foundation
import Combine

protocol NetworkManagerProtocol {
    func fetch<T: Codable>(url: String, type: T.Type) -> AnyPublisher<T, Error>
}
