//
//  NearEarthObjectViewControllerTests.swift
//  NASAappTests
//
//  Created by Piotr Nietrzebka on 20/12/2024.
//

import XCTest
@testable import NASAapp

class NearEarthObjectViewControllerTests: XCTestCase {

    var viewController: NearEarthObjectViewController!
    var viewModel: NearEarthObjectViewModelMock!

    override func setUp() {
        super.setUp()
        viewModel = NearEarthObjectViewModelMock()
        viewController = NearEarthObjectViewController(viewModel: viewModel)
        viewController.loadViewIfNeeded()
    }

    override func tearDown() {
        viewController = nil
        viewModel = nil
        super.tearDown()
    }

    func testBindViewModel() {
        // Arrange
        let expectation = XCTestExpectation(description: "ViewModel should be bound")
        viewModel.isDataLoaded = false

        // Act
        viewController.bind(viewModel: viewModel)
        
        // Assert
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
            XCTAssertTrue(self.viewModel.isDataLoaded)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func testTableViewNumberOfRowsInSection() {
        // Arrange
        viewController.bind(viewModel: viewModel)
        viewController.loadViewIfNeeded()
        if viewModel.isDataLoaded {
            viewController.tableView.reloadData()
        }
        
        // Act
        let rows = viewController.tableView(viewController.tableView, numberOfRowsInSection: 0)

        // Assert
        XCTAssertEqual(rows, 3)
    }
}
