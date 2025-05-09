//
//  asincronismo_aentrenaTests.swift
//  asincronismo_aentrenaTests
//
//  Created by Álvaro Entrena Casas on 9/5/25.
//

import XCTest
import Combine
import AsincLibrary
import CombineCocoa
import UIKit
@testable import asincronismo_aentrena

final class KCDragonBallProfTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testKeyChainLibrary() throws {
        let KC = KeychainManager.shared
        XCTAssertNotNil(KC)
        
        let save = KC.setKC(key: "Test", value: "123")
        XCTAssertEqual(save, true)
        
        let value = KC.getKC(key: "Test")
        if let valor = value {
            XCTAssertEqual(valor, "123")
        }
        XCTAssertNoThrow(KC.removeKC(key: "Test"))
    }
    
    func testLoginFake() async throws {
        let KC = KeychainManager.shared
        XCTAssertNotNil(KC)
        
        
        let obj = FakeLoginUseCase()
        XCTAssertNotNil(obj)
        
        //Validate Token
        let resp = await obj.validateToken()
        XCTAssertEqual(resp, true)
        
        
        // login
        let loginDo = await obj.login(user: "", password: "")
        XCTAssertEqual(loginDo, true)
        var jwt = KC.getKC(key: ConstantsApp.CONST_TOKEN_ID_KEYCHAIN)
        XCTAssertNotEqual(jwt, "")
        
        //Close Session
        await obj.logout()
        jwt = KC.getKC(key: ConstantsApp.CONST_TOKEN_ID_KEYCHAIN)
        XCTAssertEqual(jwt, "")
    }
    
    func testLoginReal() async throws  {
        let CK = KeychainManager.shared
        XCTAssertNotNil(CK)
        //reset the token
        let _ = CK.setKC(key: ConstantsApp.CONST_TOKEN_ID_KEYCHAIN, value: "")
        
        //Caso se uso con repo Fake
        let userCase = DefaultLoginUseCase(repo: LoginRepositoryFake())
        XCTAssertNotNil(userCase)
        
        //validacion
        let resp = await userCase.validateToken()
        XCTAssertEqual(resp, false)
        
        //login
        let loginDo = await userCase.login(user: "", password: "")
        XCTAssertEqual(loginDo, true)
        var jwt = CK.getKC(key: ConstantsApp.CONST_TOKEN_ID_KEYCHAIN)
        XCTAssertNotEqual(jwt, "")
        
        //Close Session
        await userCase.logout()
        jwt = CK.getKC(key: ConstantsApp.CONST_TOKEN_ID_KEYCHAIN)
        XCTAssertEqual(jwt, "")
    }
    
    func testLoginAutoLoginAsincrono()  throws  {
        var suscriptor = Set<AnyCancellable>()
        let exp = self.expectation(description: "Login Auto ")
        
        let vm = AppState(loginUseCase: FakeLoginUseCase())
        XCTAssertNotNil(vm)
        
        vm.$loginStatus
            .sink { completion in
                switch completion{
                    
                case .finished:
                    print("finalizado")
                }
            } receiveValue: { estado in
                print("Recibo estado \(estado)")
                if estado == .success {
                    exp.fulfill()
                }
            }
            .store(in: &suscriptor)

         vm.validateLogin()
        
        self.waitForExpectations(timeout: 10)
    }
    
    func testUIErrorView() async throws  {

        let appStateVM = AppState(loginUseCase: FakeLoginUseCase())
        XCTAssertNotNil(appStateVM)

        appStateVM.loginStatus = .error
        
        let vc = await ErrorViewController(appState: appStateVM, error: "Error Testing")
        XCTAssertNotNil(vc)
    }
    
    func testUILoginView()  throws  {
        XCTAssertNoThrow(LoginView())
        let view = LoginView()
        XCTAssertNotNil(view)
        
        let logo =   view.logoImage
        XCTAssertNotNil(logo)
        let txtUser = view.emailTextfield
        XCTAssertNotNil(txtUser)
        let txtPass = view.passwordTextfield
        XCTAssertNotNil(txtPass)
        let button = view.buttonLogin
        XCTAssertNotNil(button)
        
        //Ojo, aqui hay que testear con la variable localizada
        XCTAssertEqual(txtUser.placeholder, NSLocalizedString("email", comment: ""))
        XCTAssertEqual(txtPass.placeholder, NSLocalizedString("password", comment: ""))
        XCTAssertEqual(button.titleLabel?.text, NSLocalizedString("login", comment: ""))
        
        
        //la vista esta generada
       let View2 =  LoginViewController(appState: AppState(loginUseCase: FakeLoginUseCase()))
       XCTAssertNotNil(View2)
        XCTAssertNoThrow(View2.loadView()) //generamos la vista
        XCTAssertNotNil(View2.loginButton)
        XCTAssertNotNil(View2.emailTextfield)
        XCTAssertNotNil(View2.logo)
        XCTAssertNotNil(View2.passwordTexfield)
        
        //el binding
        XCTAssertNoThrow(View2.bindUI())
        
        View2.emailTextfield?.text = "Hola"
        
        //el boton debe estar desactivado
        XCTAssertEqual(View2.emailTextfield?.text, "Hola")
    }
    
    func testHeroiewViewModel() async throws  {
        let vm = HerosViewModel(useCase: FakeHeroUseCase())
        XCTAssertNotNil(vm)
        XCTAssertEqual(vm.heros.count, 2) //debe haber 2 heroes Fake mokeados
    }
    
    func testHerosUseCase() async throws  {
       let caseUser = HeroUseCase(repo: HerosRepositoryFake())
        XCTAssertNotNil(caseUser)
        
        let data = await caseUser.getHeros(filter: "")
        XCTAssertNotNil(data)
        XCTAssertEqual(data.count, 2)
    }
    
    func testHeros_Combine() async throws  {
        var suscriptor = Set<AnyCancellable>()
        let exp = self.expectation(description: "Heros get")
        
        let vm = HerosViewModel(useCase: FakeHeroUseCase())
        XCTAssertNotNil(vm)
        
        vm.$heros
            .sink { completion in
                switch completion{
                    
                case .finished:
                    print("finalizado")
                }
            } receiveValue: { data in
      
                if data.count == 2 {
                    exp.fulfill()
                }
            }
            .store(in: &suscriptor)
      
        
        await self.waitForExpectations(timeout: 10)
    }
    
    func testHeros_Data() async throws  {
        let network = NetworkHerosMock()
        XCTAssertNotNil(network)
        let repo = HerosRepository(network: network)
        XCTAssertNotNil(repo)
        
        let repo2 = HerosRepositoryFake()
        XCTAssertNotNil(repo2)
        
        let data = await repo.getHeros(fitler: "")
        XCTAssertNotNil(data)
        XCTAssertEqual(data.count, 2)
        
        
        let data2 = await repo2.getHeros(fitler: "")
        XCTAssertNotNil(data2)
        XCTAssertEqual(data2.count, 2)
    }
    
    func testHeros_Domain() async throws  {
       //Models
        let model = HerosModel(id: UUID(), favorite: true, description: "des", photo: "url", name: "goku")
        XCTAssertNotNil(model)
        XCTAssertEqual(model.name, "goku")
        XCTAssertEqual(model.favorite, true)
        
        let requestModel = HeroModelRequest(name: "goku")
        XCTAssertNotNil(requestModel)
        XCTAssertEqual(requestModel.name, "goku")
    }
    
    func testHeros_Presentation() async throws  {
        let viewModel = HerosViewModel(useCase: FakeHeroUseCase())
        XCTAssertNotNil(viewModel)
        
        let view =  await HerosTableViewController(appState: AppState(loginUseCase: FakeLoginUseCase()), viewModel: viewModel)
        XCTAssertNotNil(view)
        
    }
}
