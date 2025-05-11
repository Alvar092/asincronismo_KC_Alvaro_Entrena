//
//  HeroDetailViewModel.swift
//  asincronismo_aentrena
//
//  Created by Álvaro Entrena Casas on 10/5/25.
//

import Foundation
import Combine

final class HeroDetailViewModel: ObservableObject {
    
    // Lista de transformaciones
    @Published var heroName = ""
    @Published var heroImage = ""
    @Published var heroDescription = ""
    @Published var transformations = [TransformationModel]()
    @Published var isLoading: Bool = false
    @Published var errorMesage: String?
    
    // Combine
    var suscriptors = Set<AnyCancellable>()
    private var useCaseTransformations: TransformationsUseCaseProtocol
    private let hero: HerosModel
    
    init(hero: HerosModel, useCase: TransformationsUseCaseProtocol = TransformationsUseCase()) {
        self.hero = hero
        self.useCaseTransformations = useCase
        Task {
            await loadHeroDetails()
            await loadTransformations()
        }
    }
    
    // Estado UI, carga, mensaje de error...
    
    func loadHeroDetails() async {
        DispatchQueue.main.async {
            self.heroName = self.hero.name ?? ""
            self.heroImage = self.hero.photo ?? ""
            self.heroDescription = self.hero.description ?? ""
        }
    }
    
    func loadTransformations() async {
        let data = await useCaseTransformations.getTransformations(filter: hero.id.uuidString)
        
        DispatchQueue.main.async {
            self.transformations = data
            self.isLoading = false
            // LOCALIZAR ESTO
            self.errorMesage = data.isEmpty ? "Este hero no contiene transformaciones" : nil
        }
    }
}
