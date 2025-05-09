import Foundation
import UIKit
import Combine

class HerosTableViewController: UITableViewController {
    private var vm = HerosViewModel()
    var sucriptors = Set<AnyCancellable>()
    private var appState: AppState?
    
    init(appState: AppState, viewModel: HerosViewModel) {
        self.appState = appState
        self.vm = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("heros-title", comment: "")
        tableView.register(UINib(nibName: "HeroTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
  //      tableView.refreshControl = UIRefreshControl()
 //       tableView.refreshControl?.addTarget(self, action: #selector(cellPullToRefresh), for: .valueChanged)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Cerrar",
            style: .plain,
            target: self,
            action: #selector(HerosTableViewController.closeSession)
        )
        configViewModel()
    }
    
    private func configViewModel() {
        self.vm.$heros
            .receive(on: DispatchQueue.main)
            .sink { _ in
                self.tableView.reloadData()
            }
            .store(in: &sucriptors)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.vm.heros.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! HeroTableViewCell
        
        let hero = self.vm.heros[indexPath.row]
        cell.heroTitleText.text = hero.name
        cell.heroImageView.loadImageRemote(url: URL(string: hero.photo)!)
        cell.selectionStyle = .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        150
    }
    
    @objc func closeSession(_ : UIBarButtonItem) {
        self.appState?.closeSessionUser()
    }

}
