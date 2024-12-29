//
//  HomeViewControllerUITests.swift
//  NASAappUITests
//
//  Created by Piotr Nietrzebka on 20/12/2024.
//

import XCTest

final class HomeViewControllerUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append("--UITest")
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    func testTableViewLoadsCorrectly() {
        // Assert that the tableView exists
        let tableView = app.tables["HomeTableView"]
        let exists = XCTNSPredicateExpectation(predicate: NSPredicate(format: "exists == true"), object: tableView)

        // Wait up to 5s to finish the launching animation
        let result = XCTWaiter().wait(for: [exists], timeout: 5.0)
        XCTAssertEqual(result, .completed, "Home TableView should exist after animation.")

        // Wait for cells to load
        let firstCell = tableView.cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5),
                      "First cell should load within 5 seconds.")
        
        // Assert cell contents
        XCTAssertTrue(firstCell.staticTexts["TestObject1"].exists,
                      "First cell should display the correct title.")
    }
    
    func testTableViewScroll() {
        // Assert that the tableView exists
        let tableView = app.tables["HomeTableView"]
        let exists = XCTNSPredicateExpectation(predicate: NSPredicate(format: "exists == true"), object: tableView)

        // Wait up to 5s to finish the launching animation
        let result = XCTWaiter().wait(for: [exists], timeout: 5.0)
        XCTAssertEqual(result, .completed, "Home TableView should exist after animation.")
        
        // Scroll to the bottom
        tableView.swipeUp()
        tableView.swipeUp()
        
        // Assert last cell existence (depends on mock data)
        let lastCell = tableView.cells.element(boundBy: tableView.cells.count - 1)
        XCTAssertTrue(lastCell.exists, "Last cell should exist after scrolling.")
    }

    func testNavigationToDetailView() {
        // Assert that the tableView exists
        let tableView = app.tables["HomeTableView"]
        let exists = XCTNSPredicateExpectation(predicate: NSPredicate(format: "exists == true"), object: tableView)

        // Wait up to 5s to finish the launching animation
        let result = XCTWaiter().wait(for: [exists], timeout: 5.0)
        XCTAssertEqual(result, .completed, "Home TableView should exist after animation.")
        
        XCTAssertTrue(tableView.cells.count>0, "Home TableView should have at least 1 cell.")
        
        let firstCell = tableView.cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5), "First cell should load within 5 seconds.")
        
        // on some simulators the first cell has {inf,inf,0,0} coords, and fails to tap; use appropriate simulator please
        firstCell.tap()
        
        // Assert detail view is displayed
        let detailView = app.otherElements["DetailView"]
        XCTAssertTrue(detailView.waitForExistence(timeout: 5), "Detail view should be displayed after tapping a cell.")
    }

}
