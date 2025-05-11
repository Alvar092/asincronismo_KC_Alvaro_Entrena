//
//  HerosViewModel.swift
//  asincronismo_aentrena
//
//  Created by Álvaro Entrena Casas on 9/5/25.
//

import Foundation
import Combine

final class HerosViewModel: ObservableObject {
    //Lista de heroes
    @Published var heros = [HerosModel]()
    
    //Combine
    var suscriptors = Set<AnyCancellable>()
    private var useCaseHeros: HeroUseCaseProtocol
    
    init(useCase: HeroUseCaseProtocol = HeroUseCase()) {
        self.useCaseHeros = useCase
        Task{
            await loadHeros()
        }
    }
    
    func loadHeros() async {
        let data = await useCaseHeros.getHeros(filter: "")
        
        DispatchQueue.main.async {
            self.heros = data
        }
    }
    
    func heroWith(index: Int) -> HerosModel? {
        guard index < heros.count else {
            return nil
        }
        return heros[index]
    }
}
