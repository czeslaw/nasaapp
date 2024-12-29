//
//  HomeViewController.swift
//  NASAApp
//
//  Created by Piotr Nietrzebka on 20/12/2024.
//

import UIKit
import Combine

protocol HomeViewControllerDelegate: AnyObject {
    func onSelect(nearEarthObject: NearEarthObject)
}

protocol HomeViewControllerType: BaseViewController, UITableViewDelegate, UITableViewDataSource {
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
}

class HomeViewController: BaseViewController, HomeViewControllerType {
    private var cancelables = Set<AnyCancellable>()
    private let onRefresh = PassthroughSubject<Void, Never>()
    private let onLoadMore = PassthroughSubject<Void, Never>()
    private lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = String(localized: "home.emptyState")
        label.font = Configuration.Font.bigLabel
        label.textColor = Configuration.Color.defaultTextColor
        label.numberOfLines = 0
        return label
    }()
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .singleLine
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.reuseIdentifier)
        tableView.addSubview(refreshControl)
        tableView.accessibilityIdentifier = "HomeTableView"
        return tableView
    }()
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: String(localized: "home.pullToRefresh"))
        refreshControl.addTarget(self,
                                 action: #selector(pullToRefresh),
                                 for: .valueChanged)
        return refreshControl
    }()
    
    weak var delegate: HomeViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(emptyStateLabel)
        view.centerXAnchor.constraint(equalTo: emptyStateLabel.centerXAnchor).isActive = true
        view.centerYAnchor.constraint(equalTo: emptyStateLabel.centerYAnchor).isActive = true
        
        view.addSubview(tableView)
        view.leadingAnchor.constraint(equalTo: tableView.leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: tableView.trailingAnchor).isActive = true
        view.topAnchor.constraint(equalTo: tableView.topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: tableView.bottomAnchor).isActive = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        onRefresh.send()
    }

    override func bind(viewModel: VCViewModel) {
        let input = HomeViewModelInput(onRefresh: onRefresh.eraseToAnyPublisher(),
                                       onLoadMore: onLoadMore.eraseToAnyPublisher())

        let output = (viewModel as! HomeViewModelType).transform(input: input)
        
        output.viewState
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [unowned self] _ in
                tableView.reloadData()
                removeTableFooterSpinner()
                refreshControl.endRefreshing()
        }).store(in: &cancelables)
    }

    @objc
    func pullToRefresh() {
        onRefresh.send()
    }
    
    func loadMoreData() {
        guard let vmd = (viewModel as? HomeViewModel),
              !vmd.isLoadingMore else { return }
        
        self.addTableFooterSpinner()
        onLoadMore.send()
    }
    
    private func addTableFooterSpinner() {
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.startAnimating()
        spinner.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 44)
        tableView.tableFooterView = spinner
    }
    
    private func removeTableFooterSpinner() {
        tableView.tableFooterView = nil
    }
}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let vmd = (viewModel as? HomeViewModel),
              indexPath.section >= 0,
              indexPath.section < vmd.homeSectionViewModels.count,
              indexPath.row >= 0,
              indexPath.row < vmd.homeSectionViewModels[indexPath.section].nearEarthObjects.count else {
            return
        }

        let section = vmd.homeSectionViewModels[indexPath.section]
        delegate?.onSelect(nearEarthObject: section.nearEarthObjects[indexPath.row])
    }
}

extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let vmd = (viewModel as? HomeViewModel),
              section >= 0,
              section < vmd.homeSectionViewModels.count
        else {
            return nil
        }
        
        return vmd.homeSectionViewModels[section].date.apiFormat
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let vmd = (viewModel as? HomeViewModel) else {
            return 0
        }

        return vmd.homeSectionViewModels.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let vmd = (viewModel as? HomeViewModel),
              section >= 0,
              section < vmd.homeSectionViewModels.count
        else {
            return 0
        }

        return vmd.homeSectionViewModels[section].nearEarthObjects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let vmd = (viewModel as? HomeViewModel),
              indexPath.section >= 0,
              indexPath.section < vmd.homeSectionViewModels.count,
              indexPath.row >= 0,
              indexPath.row < vmd.homeSectionViewModels[indexPath.section].nearEarthObjects.count
        else {
            return UITableViewCell()
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.reuseIdentifier, for: indexPath)
        cell.selectionStyle = .none
        
        let cellVM = vmd.homeSectionViewModels[indexPath.section].nearEarthObjects[indexPath.row]
        
        var config = UIListContentConfiguration.subtitleCell()
        
        config.text = cellVM.name
        config.textProperties.font = Configuration.Font.label
        
        config.secondaryText = cellVM.shortDesc
        config.secondaryTextProperties.font = Configuration.Font.text
        
        cell.contentConfiguration = config
        
        cell.accessibilityIdentifier = "Cell_\(cellVM.name ?? "")"
        
        if indexPath.section == vmd.homeSectionViewModels.count - 1 {
            loadMoreData()
        }
        
        return cell
    }
}
