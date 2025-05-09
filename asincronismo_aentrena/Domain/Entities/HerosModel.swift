//
//  HerosModel.swift
//  asincronismo_aentrena
//
//  Created by Álvaro Entrena Casas on 9/5/25.
//

import Foundation

struct HerosModel: Codable {
    let id: UUID
    let favorite: Bool
    let description: String
    let photo: String
    let name: String
}

//Filter the request od Heros by name
struct HeroModelRequest: Codable {
    let name: String
}
