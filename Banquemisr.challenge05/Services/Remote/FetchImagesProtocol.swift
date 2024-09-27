//
//  FetchImagesProtocol.swift
//  Banquemisr.challenge05
//
//  Created by ios on 28/09/2024.
//

import Foundation
import Combine
import UIKit

protocol MovieViewModelProtocol {
    func fetchImage(for movie: Movie) -> AnyPublisher<UIImage?, Never>
}
