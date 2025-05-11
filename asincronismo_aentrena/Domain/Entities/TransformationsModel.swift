//
//  TransformationsModel.swift
//  asincronismo_aentrena
//
//  Created by Álvaro Entrena Casas on 10/5/25.
//

import Foundation

struct TransformationModel: Codable {
    let name: String
    let photo: String
    let id: String
    let description: String
    let hero: HerosModel
}

// Filtrar la solicitud a la API a traves del nombre
struct TransformationsModelRequest: Codable {
    let id: String 
}
