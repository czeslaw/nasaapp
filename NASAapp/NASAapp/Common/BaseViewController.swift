//
//  BaseViewController.swift
//  NASAApp
//
//  Created by Piotr Nietrzebka on 20/12/2024.
//

import Foundation
import UIKit

class BaseViewController: UIViewController {
    let viewModel: VCViewModel
    
    init(viewModel: VCViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        generateSubviews(viewModel: viewModel)
        configure(viewModel: viewModel)
        bind(viewModel: viewModel)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.rightBarButtonItem = viewModel.rightBarButtonItem
        navigationItem.setHidesBackButton(viewModel.hidesBackButton, animated: false)
    }
    
    func configure(viewModel: VCViewModel) {
        view.backgroundColor = viewModel.backgroundColor
        navigationItem.title = viewModel.title
    }
    
    func bind(viewModel: VCViewModel) {
        
    }

    func generateSubviews(viewModel: VCViewModel) {
        
    }
}
