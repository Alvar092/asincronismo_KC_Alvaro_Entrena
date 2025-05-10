//
//  TransformationsUseCase.swift
//  asincronismo_aentrena
//
//  Created by Álvaro Entrena Casas on 10/5/25.
//

import Foundation

protocol TransformationsUseCaseProtocol {
    var repo: TransformationsRepositoryProtocol { get set }
    func getTransformations(filter: String) async -> [TransformationModel]
}

final class TransformationsUseCase: TransformationsUseCaseProtocol {
    
    var repo: TransformationsRepositoryProtocol
    
    init(repo: TransformationsRepositoryProtocol = TransformationsRepository(network: NetworkTransformations())) {
        self.repo = repo
    }
    
    func getTransformations(filter: String) async -> [TransformationModel] {
        return await repo.getTransformations(fitler: filter)
    }
}

final class FakeTransformationsUseCase: TransformationsUseCaseProtocol {
    var repo: TransformationsRepositoryProtocol
    
    init(repo: TransformationsRepositoryProtocol = TransformationsRepositoryFake()) {
        self.repo = repo
    }
    
    func getTransformations(filter: String) async -> [TransformationModel] {
        return await repo.getTransformations(fitler: filter)
    }
}
