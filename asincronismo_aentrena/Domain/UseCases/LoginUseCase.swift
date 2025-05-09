//
//  LoginUsecase.swift
//  asincronismo_aentrena
//
//  Created by Álvaro Entrena Casas on 8/5/25.
//

import Foundation
import AsincLibrary

protocol LoginUseCase {
    //var repo: LoginRepositoryProtocol { get }
    func login(user: String, password: String) async -> Bool
    func logout() async
    func validateToken() async -> Bool
}

final class DefaultLoginUseCase: LoginUseCase {
    var repo: any LoginRepositoryProtocol
    
    init(repo: LoginRepositoryProtocol = DefaultLoginRepository(network: NetworkLogin())) {
        self.repo = repo
    }
    
    func login(user: String, password: String) async -> Bool {
        let token = await repo.loginApp(user: user, pass: password)
        
        if token != "" {
            return KeychainManager.shared.setKC(key: ConstantsApp.CONST_TOKEN_ID_KEYCHAIN, value: token)
        } else {
            let _ = KeychainManager.shared.removeKC(key: ConstantsApp.CONST_TOKEN_ID_KEYCHAIN)
            return false
        }
    }
    
    func logout() async {
        let _ = KeychainManager.shared.removeKC(key: ConstantsApp.CONST_TOKEN_ID_KEYCHAIN)
    }
        
    func validateToken() async -> Bool {
        KeychainManager.shared.getKC(key: ConstantsApp.CONST_TOKEN_ID_KEYCHAIN) != ""
    }
}

final class FakeLoginUseCase: LoginUseCase {
    var repo: any LoginRepositoryProtocol
    
    init(repo: LoginRepositoryProtocol = LoginRepositoryFake()) {
        self.repo = repo
    }
    
    func login(user: String, password: String) async -> Bool {
        let token = await repo.loginApp(user: user, pass: password)
        return KeychainManager.shared.setKC(key: ConstantsApp.CONST_TOKEN_ID_KEYCHAIN, value: "LoginFakeSuccess")
    }
    
    func logout() async {
        let _ = KeychainManager.shared.removeKC(key: ConstantsApp.CONST_TOKEN_ID_KEYCHAIN)
    }
        
    func validateToken() async -> Bool {
        return true
    }
}
