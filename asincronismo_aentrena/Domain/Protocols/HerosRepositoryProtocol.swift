//
//  HerosRepositoryProtocol.swift
//  asincronismo_aentrena
//
//  Created by Álvaro Entrena Casas on 9/5/25.
//

import Foundation

protocol HerosRepositoryProtocol {
    func getHeros(fitler: String) async -> [HerosModel]
}
