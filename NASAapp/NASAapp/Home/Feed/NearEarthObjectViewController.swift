//
//  NearEarthViewObjectViewController.swift
//  NASAApp
//
//  Created by Piotr Nietrzebka on 20/12/2024.
//

import UIKit
import Combine

protocol NearEarthObjectViewControllerDelegate: AnyObject {
    func didPressShare(nearEarthObject: NearEarthObject)
}

class NearEarthObjectViewController: BaseViewController {
    private var cancelables = Set<AnyCancellable>()
    private let onAppear = PassthroughSubject<Void, Never>()
    private let imageSize: CGFloat = ScreenChecker.isIPad ? 400 : 200
    weak var delegate: NearEarthObjectViewControllerDelegate?

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: UITableView.Style.grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .singleLine
        tableView.register(UITableViewCell.self,
                           forCellReuseIdentifier: UITableViewCell.reuseIdentifier)
        tableView.accessibilityIdentifier = "NearEarthObjectTableView"
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableView)
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        onAppear.send()
    }
    
    override func bind(viewModel: VCViewModel) {
        let input = NearEarthObjectViewModelInput(onAppear: onAppear.eraseToAnyPublisher())
        
        let output = (viewModel as! NearEarthObjectViewModelType).transform(input: input)
        
        output.viewState
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [unowned self] state in
                switch state {
                case .success(let nearEarthObject):
                    guard let vmd = self.viewModel as? NearEarthObjectViewModel,
                    let nearEarthObject = nearEarthObject else {
                        break
                    }
                    vmd.nearEarthObject = nearEarthObject
                    self.generateSubviews(viewModel: viewModel)
                case .failure(let error):
                    debugPrint("error\(error)")
                case .share(let nearEarthObject):
                    self.delegate?.didPressShare(nearEarthObject: nearEarthObject)
                }
        }).store(in: &cancelables)
    }
    
    override func generateSubviews(viewModel: VCViewModel) {
        super.generateSubviews(viewModel: viewModel)

        tableView.reloadData()
    }
}

extension NearEarthObjectViewController: UITableViewDelegate {
    
}

extension NearEarthObjectViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let vmd = (viewModel as? NearEarthObjectViewModelType) else {
            return 0
        }

        return vmd.cellViewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let vmd = (viewModel as? NearEarthObjectViewModel),
              indexPath.row >= 0,
              indexPath.row < vmd.cellViewModels.count else {
            return UITableViewCell()
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.reuseIdentifier, for: indexPath)
        cell.selectionStyle = .none
        
        let cellVM = vmd.cellViewModels[indexPath.row]
        
        var config = UIListContentConfiguration.subtitleCell()
        
        config.text = cellVM.detail
        config.textProperties.font = Configuration.Font.label
        
        config.secondaryText = cellVM.title
        config.secondaryTextProperties.font = Configuration.Font.text
        
        cell.contentConfiguration = config
        
        return cell
    }
}
