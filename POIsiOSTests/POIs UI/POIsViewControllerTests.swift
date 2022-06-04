//
// Created by Mate Csengeri on 2022. 06. 04. 
	

import XCTest
import POIsiOS
import POIs

class POIsViewControllerTests: XCTestCase {

    func test_loadPoisAction_requestPoisFromLoader() {
        let loader = LoaderSpy()
        let sut = POIsViewController(loader: loader)
        XCTAssertEqual(0, loader.loadPoisCallCount, "Expected no loading before view is loaded")
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(1, loader.loadPoisCallCount, "Expected loading after view loaded")
        
        sut.simulateUserInitiatedPOIsReload()
        XCTAssertEqual(2, loader.loadPoisCallCount, "Expected another loading request when user initiates a reload")
        
        sut.simulateUserInitiatedPOIsReload()
        XCTAssertEqual(3, loader.loadPoisCallCount, "Expected another loading request when user initiates a reload")
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
