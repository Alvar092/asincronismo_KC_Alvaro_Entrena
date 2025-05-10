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
    @IBOutlet weak var heroDescriptionTextView: UITextView!
    @IBOutlet weak var transformationsStackView: UIStackView!
    
    var appState: AppState?
    
    init(appState: AppState) {
        self.appState = appState
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }



}
