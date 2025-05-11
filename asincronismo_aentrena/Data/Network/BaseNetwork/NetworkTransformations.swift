//
//  NetworkTransformations.swift
//  asincronismo_aentrena
//
//  Created by Álvaro Entrena Casas on 10/5/25.
//

import Foundation
import AsincLibrary

protocol NetworkTransformationsProtocol {
    func getTransformations(filter: String) async -> [TransformationModel]
}

final class NetworkTransformations: NetworkTransformationsProtocol {
    func getTransformations(filter: String) async -> [TransformationModel] {
        var modelReturn = [TransformationModel]()
        
        let url: String = "\(ConstantsApp.CONST_API_URL)\(EndPoints.transformations.rawValue)"
        var request: URLRequest = URLRequest(url: URL(string: url)!)
        request.httpMethod = HTTPMethods.post
        request.httpBody = try? JSONEncoder().encode(TransformationsModelRequest(id: filter))
        request.addValue(HTTPMethods.content, forHTTPHeaderField: "Content-type")
        
        // Token JWT a algo generico o interceptor?
        let JwtToken = KeychainManager.shared.getKC(key: ConstantsApp.CONST_TOKEN_ID_KEYCHAIN)
        if let tokenJWT = JwtToken{
            request.addValue("Bearer \(tokenJWT)", forHTTPHeaderField: "Authorization") // Token
        }
        
        // Call to server
        do{
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let resp = response  as? HTTPURLResponse {
                if resp.statusCode == HTTPResponseCodes.SUCCESS {
                    modelReturn = try JSONDecoder().decode([TransformationModel].self, from: data)
                }
            }
            
        }catch{
            print("Hay error")
        }
        
        return modelReturn
    }
}

final class NetworkTransformationsMock: NetworkTransformationsProtocol {
    func getTransformations(filter: String) async -> [TransformationModel] {
        return getTransformationsFromJson()
    }
}

func getTransformationsFromJson() -> [TransformationModel] {
    if let url = Bundle.main.url(forResource: "transformations", withExtension: "json") {
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
        let jsonData = try decoder.decode([TransformationModel].self, from: data)
            return jsonData
        } catch {
            print("error:\(error)")
        }
    }
    return []
}
