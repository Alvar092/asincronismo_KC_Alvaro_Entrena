//
//  TransformationsModel.swift
//  asincronismo_aentrena
//
//  Created by Álvaro Entrena Casas on 10/5/25.
//

import Foundation

struct TransformationModel: Codable {
    let photo: String
    let hero: HerosModel
    let id: String
    let name: String
    let description: String
}

// Filtrar la solicitud a la API a traves del nombre
struct TransformationsModelRequest: Codable {
    let id: String 
}
