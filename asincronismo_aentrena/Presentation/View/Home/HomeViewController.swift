//
//  HomeViewController.swift
//  asincronismo_aentrena
//
//  Created by Álvaro Entrena Casas on 9/5/25.
//

import UIKit

class HomeViewController: UIViewController {

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
    
    
    @IBAction func closeSession(_ sender: Any) {
        self.appState?.closeSessionUser()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
