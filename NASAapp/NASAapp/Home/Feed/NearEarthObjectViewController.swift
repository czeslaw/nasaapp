//
//  NearEarthViewObjectViewController.swift
//  NASAApp
//
//  Created by Piotr Nietrzebka on 20/12/2024.
//

import UIKit
import Combine

protocol NearEarthObjectViewControllerDelegate: AnyObject {
    func didPressShare(nearEarthObject: NearEarthObject, image: UIImage?)
}

class NearEarthObjectViewController: BaseViewController {
    enum NearEarthObjectViewControllerSection: Int, CaseIterable {
        case image = 0
        case details
    }
    
    private var cancelables = Set<AnyCancellable>()
    private let onAppear = PassthroughSubject<Void, Never>()
    private let imageSize: CGFloat = ScreenChecker.isIPad ? 400 : 200
    
    weak var delegate: NearEarthObjectViewControllerDelegate?

    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        
        imageView.heightAnchor.constraint(equalToConstant: imageSize).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: imageSize).isActive = true
        
        return imageView
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: UITableView.Style.grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .singleLine
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.reuseIdentifier)
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
        
        let output = (viewModel as! NearEarthObjectViewModel).transform(input: input)
        
        output.viewState
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [unowned self] state in
                switch state {
                case .success(let nearEarthObject):
                    guard let vm = self.viewModel as? NearEarthObjectViewModel,
                    let nearEarthObject = nearEarthObject else {
                        break
                    }
                    vm.nearEarthObject = nearEarthObject
                    self.generateSubviews(viewModel: viewModel)
                case .failure(let error):
                    debugPrint("error\(error)")
                case .share(let nearEarthObject):
                    self.delegate?.didPressShare(nearEarthObject: nearEarthObject,
                                                 image: imageView.image)
                }
        }).store(in: &cancelables)
    }
    
    override func generateSubviews(viewModel: VCViewModel) {
        super.generateSubviews(viewModel: viewModel)
        
//        guard let vm = viewModel as? FeedViewModel else {
//            return
//        }
//        if let url = URL(string: vm.feed.nasa_jpl_url ?? "") {
//            imageView.imageFromURL(url: url)
//        }
        
        tableView.reloadData()
    }
}

extension NearEarthObjectViewController: UITableViewDelegate {
    
}

extension NearEarthObjectViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return NearEarthObjectViewControllerSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = NearEarthObjectViewControllerSection(rawValue: section) else {
            return 0
        }
        
        switch section {
        case .image:
            return 0
        case .details:
            guard let vm = (viewModel as? NearEarthObjectViewModel) else {
                return 0
            }

            return vm.cellViewModels.count
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let section = NearEarthObjectViewControllerSection(rawValue: section) else {
            return nil
        }
        
        switch section {
        case .image:
            
            let view = UIView(frame: CGRect(x: 0,
                                            y: 0,
                                            width: imageSize*1.5,
                                            height: imageSize*1.5))
            view.addSubview(imageView)
            
            view.centerXAnchor.constraint(equalTo: imageView.centerXAnchor).isActive = true
            view.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
            
            return view
        case .details:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let section = NearEarthObjectViewControllerSection(rawValue: section) else {
            return 0
        }
        switch section {
        case .image:
            return imageSize*1.5
        case .details:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let vm = (viewModel as? NearEarthObjectViewModel),
              indexPath.row >= 0,
              indexPath.row < vm.cellViewModels.count else {
            return UITableViewCell()
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.reuseIdentifier, for: indexPath)
        cell.selectionStyle = .none
        
        let cellVM = vm.cellViewModels[indexPath.row]
        
        var config = UIListContentConfiguration.subtitleCell()
        
        config.text = cellVM.detail
        config.textProperties.font = Configuration.Font.label
        
        config.secondaryText = cellVM.title
        config.secondaryTextProperties.font = Configuration.Font.text
        
        cell.contentConfiguration = config
        
        return cell
    }
}
