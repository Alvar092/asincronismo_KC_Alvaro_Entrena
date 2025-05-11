//
//  HeroDetailViewController.swift
//  asincronismo_aentrena
//
//  Created by Álvaro Entrena Casas on 10/5/25.
//

import UIKit
import Combine
import CombineCocoa

class HeroDetailViewController: UIViewController {

    @IBOutlet weak var heroNameLabel: UILabel!
    @IBOutlet weak var heroImageView: UIImageView!
    @IBOutlet weak var heroDescriptionLabel: UILabel!
    @IBOutlet weak var transformationsStackView: UIStackView!
    
    var appState: AppState?
    var subscriptions = Set<AnyCancellable>()
    private var viewModel: HeroDetailViewModel
    private var hero: HerosModel
    
    init(appState: AppState?, hero: HerosModel, viewModel: HeroDetailViewModel? = nil) {
        self.appState = appState
        self.viewModel = viewModel ?? HeroDetailViewModel(hero: hero)
        self.hero = hero
        super.init(nibName: "HeroDetailViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureHeroDetails()
        setUpBindings()
    }
    
    func configureHeroDetails() {
        heroNameLabel.text = hero.name
        heroImageView.loadImageRemote(url: URL(string: hero.photo ?? "")!)
        heroDescriptionLabel.text = hero.description
    }
    
    func setUpBindings() {
        viewModel.$transformations
            .receive(on: RunLoop.main)
            .sink { [weak self] transformations in
                self?.updateTransformationsUI(with: transformations)
            }
            .store(in: &subscriptions)
    }
    
    func updateTransformationsUI(with transformations: [TransformationModel]) {
        // Limpiamos el stack view
        transformationsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Si no hay transformaciones, mostramos mensaje al usuario
        if transformations.isEmpty {
            let label = UILabel()
            // LOCALIZAR ESTO
            label.text = NSLocalizedString("No transformations", comment: "El heroe no contiene transformaciones")
            label.textAlignment = .center
            transformationsStackView.addArrangedSubview(label)
        } else {
            for transformation in transformations {
                let card = TransformationCardView()
                card.configure(with: transformation)
                card.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    card.widthAnchor.constraint(equalToConstant: 368),
                    card.heightAnchor.constraint(equalToConstant: 140)
                ])
                transformationsStackView.addArrangedSubview(card)
            }
        }
    }
}
