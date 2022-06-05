//
// Created by Mate Csengeri on 2022. 06. 04. 
	

import XCTest
import POIsiOS
import POIs

class POIsViewControllerTests: XCTestCase {

    func test_loadPoisAction_requestPoisFromLoader() {
        let (sut, loader) = makeSUT()
        XCTAssertEqual(0, loader.loadPoisCallCount, "Expected no loading before view is loaded")
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(1, loader.loadPoisCallCount, "Expected loading after view loaded")
        
        sut.simulateUserInitiatedPOIsReload()
        XCTAssertEqual(2, loader.loadPoisCallCount, "Expected another loading request when user initiates a reload")
        
        sut.simulateUserInitiatedPOIsReload()
        XCTAssertEqual(3, loader.loadPoisCallCount, "Expected another loading request when user initiates a reload")
    }
    
    func test_loadIndicator_isvisibleWhileLoadingPois() {
        let (sut, loader) = makeSUT()
        XCTAssertEqual(sut.isRefreshing, false, "Should not loading before the view appear")
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.isRefreshing, true, "Expect loading after view appear, but before the loader comleting")
        
        loader.completeWithSuccess([], at: 0)
        XCTAssertEqual(sut.isRefreshing, false, "Expect not loading after completing the loader")
        
        sut.simulateUserInitiatedPOIsReload()
        XCTAssertEqual(sut.isRefreshing, true, "Expect loading after user triggered the reload, but before the loader comleting")
        
        loader.completeWithError(at: 1)
        XCTAssertEqual(sut.isRefreshing, false, "Expect not loading after completing the loader")
    }
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (POIsViewController, LoaderSpy) {
        let loader = LoaderSpy()
        let sut = POIsViewController(loader: loader)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }

}

private class LoaderSpy: POILoader {
    
    private var loadRequests = [(POILoader.Result) -> Void]()
    
    var loadPoisCallCount: Int {
        return loadRequests.count
    }
    
    func load(completion: @escaping (POILoader.Result) -> Void) {
        loadRequests.append(completion)
    }
    
    func completeWithSuccess(_ pois: [POI], at index: Int) {
        loadRequests[index](.success(pois))
    }
    
    func completeWithError(at index: Int) {
        loadRequests[index](.failure(anyNSError))
    }
    
    
}

private var anyNSError: Error {
    return NSError(domain: "test.error", code: 0)
}

private extension POIsViewController {
    var isRefreshing: Bool {
        refreshControl.isRefreshing
    }
    
    func simulateUserInitiatedPOIsReload() {
        refreshControl.simulatePullToRefresh()
    }
}

extension UIControl {
    func simulate(event: UIControl.Event) {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: event)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}

extension UIRefreshControl {
    func simulatePullToRefresh() {
        simulate(event: .valueChanged)
    }
}
