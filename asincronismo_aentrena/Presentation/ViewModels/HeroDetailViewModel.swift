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
    @Published var transformations = [TransformationModel]()
    
    // Combine
    var suscriptors = Set<AnyCancellable>()
    private var useCaseTransformations: TransformationsUseCaseProtocol
    
    init(useCase: TransformationsUseCaseProtocol = TransformationsUseCase()) {
        self.useCaseTransformations = useCase
        Task {
            await loadTransformations()
        }
    }
    
    // Estado UI, carga, mensaje de error...
    
    func loadTransformations() async {
        let data = await useCaseTransformations.getTransformations(filter: "")
        
        DispatchQueue.main.async {
            self.transformations = data
        }
    }
}
