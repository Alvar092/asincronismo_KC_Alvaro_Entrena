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
        // Verifica el funcionamiento básico de la libreria keychain(leer,guardar y eliminar valores)
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
        // Simula un login/logout con un caso de uso falso, verificando persistencia del token en Keychain
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
        // Simula un flujo de login realista con lógica asincrónica pero un repositorio falso.
        let CK = KeychainManager.shared
        XCTAssertNotNil(CK)
        //reset the token
        let _ = CK.setKC(key: ConstantsApp.CONST_TOKEN_ID_KEYCHAIN, value: "")
        
        //Caso de uso con repo Fake
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
        // Test asincrónico usando Combine para validar que el login automático cambia el estado correctamente.
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
        // Verifica que se puede inicializar una vista de error con un estado determinado.
        let appStateVM = AppState(loginUseCase: FakeLoginUseCase())
        XCTAssertNotNil(appStateVM)

        appStateVM.loginStatus = .error
        
        let vc = await ErrorViewController(appState: appStateVM, error: "Error Testing")
        XCTAssertNotNil(vc)
    }
    
    func testUILoginView()  throws  {
        // Test de validación de estructura visual y lógica básica de activación del login.
        
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
    
    func testHerosViewModel() async throws {
        // Test de lógica del ViewModel para listar héroes desde datos falsos.
        let vm = HerosViewModel(useCase: FakeHeroUseCase())
        await vm.loadHeros()
        XCTAssertNotNil(vm)
        XCTAssertEqual(vm.heros.count, 2) //debe haber 2 heroes Fake mokeados
    }
    
    func testHerosUseCase() async throws  {
        // Verifica la conexión del caso de uso con el repositorio.
        let caseUser = HeroUseCase(repo: HerosRepositoryFake())
        XCTAssertNotNil(caseUser)
        
        let data = await caseUser.getHeros(filter: "")
        XCTAssertNotNil(data)
        XCTAssertEqual(data.count, 2)
    }
    
    func testHeros_Combine() async throws  {
        // Test asincrónico del binding con Combine al cambiar datos en el ViewModel.
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
        //  Valida la capa de datos tanto con red mockeada como con repositorio falso.
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
        // Valida la correcta creación de modelos del dominio con sus propiedades.
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
        // Valida que la pantalla de lista de héroes se puede crear con sus dependencias.
        let viewModel = HerosViewModel(useCase: FakeHeroUseCase())
        XCTAssertNotNil(viewModel)
        
        let view =  await HerosTableViewController(appState: AppState(loginUseCase: FakeLoginUseCase()), viewModel: viewModel)
        XCTAssertNotNil(view)
        
    }
    
    func testTransformations_Data() async throws  {
        //  Valida la capa de datos tanto con red mockeada como con repositorio falso.
        let network = NetworkTransformationsMock()
        XCTAssertNotNil(network)
        let repo = TransformationsRepository(network: network)
        XCTAssertNotNil(repo)
        
        let repo2 = TransformationsRepositoryFake()
        XCTAssertNotNil(repo2)
        
        let data = await repo.getTransformations(fitler: "88960359-A208-41A9-AD47-ADA0B5433C83")
        XCTAssertNotNil(data)
        XCTAssertEqual(data.count, 6)
        
        
        let data2 = await repo2.getTransformations(fitler: "88960359-A208-41A9-AD47-ADA0B5433C83")
        XCTAssertNotNil(data2)
        XCTAssertEqual(data2.count, 6)
    }
    
    func testTransformations_Domain() async throws {
        // Valida la correcta creación del modelo de transformaciones del dominio con sus propiedades
        let transformation = TransformationModel(
            name: "name",
            photo: "photo",
            id: "id",
            description: "description",
            hero: HerosModel(id: UUID(), favorite: false, description: "Test Hero", photo: "hero_photo", name: "Goku")
            )
        XCTAssertNotNil(transformation)
        XCTAssertEqual(transformation.name, "name")
        
        let requestTransformation = TransformationsModelRequest(id: "88960359-A208-41A9-AD47-ADA0B5433C83")
        XCTAssertNotNil(requestTransformation)
        XCTAssertEqual(requestTransformation.id, "88960359-A208-41A9-AD47-ADA0B5433C83")
    }
    
    func testTransformationsUseCase() async throws  {
        // Verifica la conexión del caso de uso con el repositorio.
        let caseUser = TransformationsUseCase(repo: TransformationsRepositoryFake())
        XCTAssertNotNil(caseUser)
        
        let data = await caseUser.getTransformations(filter: "88960359-A208-41A9-AD47-ADA0B5433C83")
        XCTAssertNotNil(data)
        XCTAssertEqual(data.count, 6)
    }
    
    func testHeroDetailViewModel() async throws  {
        // Test de lógica del ViewModel para listar transformaciones desde datos falsos.
        let detailvm = HeroDetailViewModel(hero: HerosModel(id: UUID(), favorite: false, description: "description", photo: "photo", name: "name"), useCase: FakeTransformationsUseCase())
        await detailvm.loadTransformations()
        XCTAssertNotNil(detailvm)
        XCTAssertEqual(detailvm.transformations.count, 6) //debe haber 6 transformaciones Fake mokeados
    }
    
    func testHeroDetail_Presentation() async throws  {
        // Valida que la pantalla de detalles se puede crear con sus dependencias.
        let hero = HerosModel(id: UUID(), favorite: false, description: "description", photo: "photo", name: "name")
        let viewModel = HeroDetailViewModel(hero: hero, useCase: FakeTransformationsUseCase())
        XCTAssertNotNil(viewModel)
        
        let view =  await HeroDetailViewController(appState: AppState(), hero: hero)
        XCTAssertNotNil(view)
    }
    
    func testHeroDetail_Combine() async throws {
        // Suscripciones Combine
        var subscriptions = Set<AnyCancellable>()
        // Expectativa: esperar a que lleguen las transformaciones
        let exp = expectation(description: "Transformations loaded")

        // Heroe ficticio para pasar al ViewModel
        let hero = HerosModel(
            id: UUID(),
            favorite: false,
            description: "Descripción",
            photo: "https://photo.com/img.jpg",
            name: "Goku"
        )

        // ViewModel con fake use case
        let viewModel = HeroDetailViewModel(hero: hero, useCase: FakeTransformationsUseCase())

        // Esperamos a que se publiquen las transformaciones (ignoramos el valor inicial vacío)
        viewModel.$transformations
            .dropFirst()
            .sink { data in
                if data.count == 6 {
                    exp.fulfill()
                }
            }
            .store(in: &subscriptions)

        await fulfillment(of: [exp], timeout: 5)
    }
    
    func testHeroTransformations_Empty() async throws {
        let useCase = FakeTransformationsUseCase(
            repo: TransformationsRepositoryFake(network: NetworkTransformations()))
        
        let hero = HerosModel(
            id: UUID(),
            favorite: false,
            description: "Sin transformaciones",
            photo: nil,
            name: "Mr. Satán"
        )
        
        let viewModel = HeroDetailViewModel(hero: hero, useCase: useCase)

            // Esperar publicación
            try? await Task.sleep(nanoseconds: 1_000_000_000)

            XCTAssertEqual(viewModel.transformations.count, 0)
            XCTAssertEqual(viewModel.errorMesage, "Este hero no contiene transformaciones")
    }
    

    func testHeroDetailViewControllerInitialization() {
        // Creamos un héroe de prueba
        let mockHero = HerosModel(
            id: UUID(),
            favorite: false,
            description: "Genius billionaire",
            photo: "http://example.com/ironman.jpg",
            name: "Iron Man"
        )
        
        // Creamos un mock del AppState
        let mockAppState = AppState()
        
        // Creamos un mock del ViewModel
        let mockViewModel = HeroDetailViewModel(hero: mockHero)
        
        // Inicializamos el ViewController
        let viewController = HeroDetailViewController(
            appState: mockAppState,
            hero: mockHero,
            viewModel: mockViewModel
        )
        
        // Verificamos que se haya inicializado correctamente
        XCTAssertNotNil(viewController)
        viewController.loadViewIfNeeded()
        viewController.configureHeroDetails()
        XCTAssertEqual(viewController.heroNameLabel.text, mockHero.name)
    }
    
    func testConfigureHeroDetails() {
        // Creamos un héroe de prueba
        let mockHero = HerosModel(
            id: UUID(),
            favorite: false,
            description: "God of Thunder",
            photo: "http://example.com/thor.jpg",
            name: "Thor"
        )
        
        // Inicializamos el ViewController
        let viewController = HeroDetailViewController(
            appState: nil,
            hero: mockHero
        )
        
        // Cargamos la vista
        viewController.loadViewIfNeeded()
        
        // Ejecutamos el método que queremos probar
        viewController.configureHeroDetails()
        
        // Verificamos que los outlets se configuraron correctamente
        XCTAssertEqual(viewController.heroNameLabel.text, "Thor")
        XCTAssertEqual(viewController.heroDescriptionLabel.text, "God of Thunder")
        // No podemos probar directamente la carga de imagen aquí ya que es una operación asíncrona
    }
    
    func testUpdateTransformationsUIWithEmptyList() {
        // Creamos un héroe de prueba sin transformaciones
        let mockHero = HerosModel(
            id: UUID(),
            favorite: false,
            description: "Super soldier",
            photo: "http://example.com/cap.jpg",
            name: "Captain America"
        )
        
        // Inicializamos el ViewController
        let viewController = HeroDetailViewController(
            appState: nil,
            hero: mockHero
        )
        
        // Cargamos la vista
        viewController.loadViewIfNeeded()
        
        // Probamos el método con una lista vacía
        viewController.updateTransformationsUI(with: [])
        
        // Verificamos que se muestre el mensaje "No transformations"
        XCTAssertEqual(viewController.transformationsStackView.arrangedSubviews.count, 1)
        if let label = viewController.transformationsStackView.arrangedSubviews.first as? UILabel {
            XCTAssertEqual(label.text, NSLocalizedString("No transformations", comment: "El heroe no contiene transformaciones"))
        } else {
            XCTFail("Debería haber un label indicando que no hay transformaciones")
        }
    }

    
    func testHeroTableViewCellOutletsConnection() {
        // Cargamos la celda directamente del nib
        let bundle = Bundle(for: HeroTableViewCell.self)
        let nib = UINib(nibName: "HeroTableViewCell", bundle: bundle)
        
        guard let cell = nib.instantiate(withOwner: nil, options: nil).first as? HeroTableViewCell else {
            XCTFail("No se pudo crear la instancia de HeroTableViewCell desde el nib")
            return
        }
        
        // Aseguramos que los outlets están conectados
        XCTAssertNotNil(cell.heroImageView, "heroImageView debería estar conectado")
        XCTAssertNotNil(cell.heroTitleText, "heroTitleText debería estar conectado")
    }

    func testHeroTableViewCellConfiguration() {
        // Cargamos la celda directamente del nib
        let bundle = Bundle(for: HeroTableViewCell.self)
        let nib = UINib(nibName: "HeroTableViewCell", bundle: bundle)
        
        guard let cell = nib.instantiate(withOwner: nil, options: nil).first as? HeroTableViewCell else {
            XCTFail("No se pudo crear la instancia de HeroTableViewCell desde el nib")
            return
        }
        
        // Datos de prueba
        let testTitle = "Iron Man"
        let testImage = UIImage(systemName: "person.fill")
        
        // Configuramos la celda
        cell.heroTitleText.text = testTitle
        cell.heroImageView.image = testImage
        
        // Verificamos la configuración
        XCTAssertEqual(cell.heroTitleText.text, testTitle)
        XCTAssertEqual(cell.heroImageView.image, testImage)
    }
    
    func testTransformationCardView_initWithFrame() {
                // Given
                let frame = CGRect(x: 0, y: 0, width: 300, height: 200)
                
                // When
                let cardView = TransformationCardView(frame: frame)
                
                // Then
                XCTAssertNotNil(cardView, "Card view should be successfully initialized with frame")
                XCTAssertNotNil(cardView.transformationImageView, "Image view should be initialized")
                XCTAssertNotNil(cardView.transformationNameLabel, "Name label should be initialized")
            }
    
    func testCommonInitLoadsXibCorrectly() {
           // Given
           let cardView = TransformationCardView(frame: CGRect(x: 0, y: 0, width: 300, height: 200))
           
           // Then
           XCTAssertNotNil(cardView.transformationImageView, "transformationImageView should be connected from the XIB")
           XCTAssertNotNil(cardView.transformationNameLabel, "transformationNameLabel should be connected from the XIB")
       }
    
    
    }
    

