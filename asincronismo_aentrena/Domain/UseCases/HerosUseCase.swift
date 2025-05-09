//
//  HerosUseCase.swift
//  asincronismo_aentrena
//
//  Created by Álvaro Entrena Casas on 9/5/25.
//

import Foundation

protocol HeroUseCaseProtocol {
    var repo: HerosRepositoryProtocol { get set }
    func getHeros(filter: String) async -> [HerosModel]
}

final class HeroUseCase: HeroUseCaseProtocol {
    var repo: HerosRepositoryProtocol
    
    init(repo: HerosRepositoryProtocol = HerosRepository(network: NetworkHeros())) {
        self.repo = repo
    }
    
    func getHeros(filter: String) async -> [HerosModel] {
        return await repo.getHeros(fitler: filter)
    }
}

final class FakeHeroUseCase: HeroUseCaseProtocol {
    var repo: HerosRepositoryProtocol
    
    init(repo: HerosRepositoryProtocol = HerosRepositoryFake()) {
        self.repo = repo
    }
    
    func getHeros(filter: String) async -> [HerosModel] {
        return await repo.getHeros(fitler: filter)
    }
}
