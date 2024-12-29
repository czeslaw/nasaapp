//
//  HomeViewModelTests.swift
//  NASAappTests
//
//  Created by Piotr Nietrzebka on 20/12/2024.
//

import XCTest
import Combine
@testable import NASAapp

class HomeViewModelTests: XCTestCase {

    private var viewModel: HomeViewModel!
    private var feedServiceMock: FeedServiceMock!
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        feedServiceMock = FeedServiceMock()
        viewModel = HomeViewModel(feedService: feedServiceMock)
        cancellables = []
    }

    override func tearDown() {
        viewModel = nil
        feedServiceMock = nil
        cancellables = nil
        super.tearDown()
    }

    func testTransform_onRefresh_successfulResponse() {
        // Arrange
        let expectation = XCTestExpectation(description: "Expected successful response")
        feedServiceMock.feedResponse = .success(Feed.testFeed())
        let input = HomeViewModelInput(onRefresh: Just(()).eraseToAnyPublisher(),
                                       onLoadMore: Empty<Void, Never>().eraseToAnyPublisher())

        // Act
        let output = viewModel.transform(input: input)

        output.viewState
            .sink(receiveCompletion: { _ in }, receiveValue: { state in
                if case let .success(viewModels) = state {
                    XCTAssertEqual(viewModels.count, 1)
                    XCTAssertEqual(viewModels.first?.date, Date.testDate())
                    expectation.fulfill()
                }
            })
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }

    func testTransform_onRefresh_failureResponse() {
        // Arrange
        let expectation = XCTestExpectation(description: "Expected failure response")
        feedServiceMock.feedResponse = .failure(NSError(domain: "Test",
                                                        code: 1,
                                                        userInfo: nil))
        let input = HomeViewModelInput(onRefresh: Just(()).eraseToAnyPublisher(),
                                       onLoadMore: Empty<Void, Never>().eraseToAnyPublisher())

        // Act
        let output = viewModel.transform(input: input)

        output.viewState
            .sink(receiveCompletion: { _ in }, receiveValue: { state in
                if case let .failure(error) = state {
                    XCTAssertNotNil(error)
                    expectation.fulfill()
                }
            })
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }
    
    func testTransform_onLoadMore_successfulResponse() {
        // Arrange
        let expectation = XCTestExpectation(description: "Expected successful load more response")
        feedServiceMock.feedResponse = .success(Feed.testFeed())
        let input = HomeViewModelInput(onRefresh: Empty<Void, Never>().eraseToAnyPublisher(),
                                       onLoadMore: Just(()).eraseToAnyPublisher())

        // Act
        let output = viewModel.transform(input: input)

        output.viewState
            .sink(receiveCompletion: { _ in }, receiveValue: { state in
                if case let .success(viewModels) = state {
                    XCTAssertEqual(viewModels.count, 1)
                    XCTAssertEqual(viewModels.first?.date, Date.testDate())
                    expectation.fulfill()
                }
            })
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }

    func testTransform_onLoadMore_failureResponse() {
        // Arrange
        let expectation = XCTestExpectation(description: "Expected failure load more response")
        feedServiceMock.feedResponse = .failure(NSError(domain: "Test", code: 1, userInfo: nil))
        let input = HomeViewModelInput(onRefresh: Empty<Void, Never>().eraseToAnyPublisher(),
                                       onLoadMore: Just(()).eraseToAnyPublisher())

        // Act
        let output = viewModel.transform(input: input)

        output.viewState
            .sink(receiveCompletion: { _ in }, receiveValue: { state in
                if case let .failure(error) = state {
                    XCTAssertNotNil(error)
                    expectation.fulfill()
                }
            })
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }

    func testTransform_emptyResponse() {
        // Arrange
        let expectation = XCTestExpectation(description: "Expected empty response")
        feedServiceMock.feedResponse = .success(nil)
        let input = HomeViewModelInput(onRefresh: Just(()).eraseToAnyPublisher(),
                                       onLoadMore: Empty<Void, Never>().eraseToAnyPublisher())

        // Act
        let output = viewModel.transform(input: input)

        output.viewState
            .sink(receiveCompletion: { _ in }, receiveValue: { state in
                if case let .failure(error) = state {
                    XCTAssertEqual(NASAError.emptyFeed, error as! NASAError)
                    expectation.fulfill()
                }
            })
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }
}

// MARK: - Mocks and Extensions

extension Feed {
    static func testFeed() -> Feed {
        return Feed(links: nil,
                    elementCount: 1,
                    nearEarthObjects: ["2024-12-29": [NearEarthObject.testObject()]])
    }
}

extension NearEarthObject {
    static func testObject() -> NearEarthObject {
        return NearEarthObject(links: nil,
                               id: "12345",
                               name: "Test Object",
                               neoReferenceId: "12345",
                               nasaJplUrl: nil,
                               absoluteMagnitudeH: nil,
                               estimatedDiameter: nil,
                               isPotentiallyHazardousAsteroid: nil,
                               isSentryObject: nil,
                               closeApproachData: [])
    }
}

extension Date {
    static func testDate() -> Date {
        return Date.apiFormatter.date(from: "2024-12-29")!
    }
}
