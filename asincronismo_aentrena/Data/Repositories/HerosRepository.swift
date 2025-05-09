//
//  HerosRepository.swift
//  asincronismo_aentrena
//
//  Created by Álvaro Entrena Casas on 9/5/25.
//

import Foundation

final class HerosRepository: HerosRepositoryProtocol {
    private var network: NetworkHerosProtocol
    
    init(network: NetworkHerosProtocol) {
        self.network = network
    }
    
    func getHeros(fitler: String) async -> [HerosModel] {
        return await network.getHeros(filter: fitler)
    }
}

final class HerosRepositoryFake: HerosRepositoryProtocol {
    private var network: NetworkHerosProtocol
    
    init(network: NetworkHerosProtocol = NetworkHerosMock()) {
        self.network = network
    }
    
    func getHeros(fitler: String) async -> [HerosModel] {
        return await network.getHeros(filter: fitler)
    }
}
