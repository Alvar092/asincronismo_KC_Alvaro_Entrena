//
//  TransformationsRepositoryProtocol.swift
//  asincronismo_aentrena
//
//  Created by Álvaro Entrena Casas on 10/5/25.
//

import Foundation

protocol TransformationsRepositoryProtocol{
    func getTransformations(fitler: String) async -> [TransformationModel]
}
