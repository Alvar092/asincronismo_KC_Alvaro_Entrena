//
//  TransformationsRepository.swift
//  asincronismo_aentrena
//
//  Created by Álvaro Entrena Casas on 10/5/25.
//

import Foundation

final class TransformationsRepository: TransformationsRepositoryProtocol {
    private var network: NetworkTransformationsProtocol
    
    init(network: NetworkTransformationsProtocol) {
        self.network = network
    }
    
    func getTransformations(fitler: String) async -> [TransformationModel] {
        return await network.getTransformations(filter: fitler)
    }
}

final class TransformationsRepositoryFake:TransformationsRepositoryProtocol {
    private var network: NetworkTransformationsProtocol
    
    init(network: NetworkTransformationsProtocol = NetworkTransformationsMock()) {
        self.network = network
    }
    
    func getTransformations(fitler: String) async -> [TransformationModel] {
        return await network.getTransformations(filter: fitler)
    }
}
