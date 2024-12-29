//
//  HomeViewControllerTests.swift
//  NASAappTests
//
//  Created by Piotr Nietrzebka on 20/12/2024.
//

import XCTest
@testable import NASAapp
import Combine

class HomeViewControllerTests: XCTestCase {

    var viewController: HomeViewControllerType!
    var viewModelMock: HomeViewModelMock!

    override func setUp() {
        super.setUp()
        viewModelMock = HomeViewModelMock()
        viewController = HomeViewController(viewModel: viewModelMock)
        viewController.loadViewIfNeeded()
    }

    override func tearDown() {
        viewController = nil
        viewModelMock = nil
        super.tearDown()
    }

    func testBindViewModel() {
        // Arrange
        let expectation = XCTestExpectation(description: "ViewModel should be bound")

        // Act
        viewController.bind(viewModel: viewModelMock)

        // Assert
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertTrue(self.viewModelMock.isDataLoaded)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }
}
