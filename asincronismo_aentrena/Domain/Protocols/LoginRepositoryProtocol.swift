//
//  LoginRepositoryProtocols.swift
//  asincronismo_aentrena
//
//  Created by Álvaro Entrena Casas on 8/5/25.
//

import Foundation

protocol LoginRepositoryProtocol {
    func loginApp(user: String, pass: String) async -> String // devuelve el token JWT
}
