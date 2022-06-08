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
    
    func test_loadPoiscompletion_rendersPois() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        
        let poiA1 = makePOI(name: "poi1", city: "ACity")
        let poiA2 = makePOI(name: "poi2", city: "ACity")
        let poiB1 = makePOI(name: "poi3", city: "BCity")
        let poiC1 = makePOI(name: "poi4", city: "CCity")
        let orderedPOIs = [[poiA1, poiA2], [poiB1], [poiC1]]
        let loadedPOIs = [poiA1, poiC1, poiB1, poiA2]
        
        loader.completeWithSuccess(loadedPOIs)
        XCTAssertEqual(loadedPOIs.count, sut.numberOfRenderedPOIs)
        
        assertThat(sut, isRendering: orderedPOIs)
    }
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (POIsViewController, LoaderSpy) {
        let loader = LoaderSpy()
        let sut = POIsViewController(loader: loader)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }
    
    private func makePOI(name: String = "a name",
                         description: String? = nil,
                         city: String = "a city",
                         address: String = "an address",
                         imageURL: URL = URL(string: "http://an-image-url.com")!,
                         longitude: Double = 47.5,
                         latitude: Double = 19.5) -> POI {
        return POI(name: name,
                   description: description,
                   city: city,
                   address: address,
                   imageURL: imageURL,
                   longitude: longitude,
                   latitude: latitude)
    }
    
    private func assertThat(_ sut: POIsViewController, isRendering pois: [[POI]], file: StaticString = #filePath, line: UInt = #line) {
        guard sut.numberOfRenderedPOIs == pois.flatMap({$0}).count else {
            XCTFail("Expected \(pois.count) pois, got \(sut.numberOfRenderedPOIs) instead.", file: file, line: line)
            return
        }
        
        pois.enumerated().forEach { section, poisInSection in
            poisInSection.enumerated().forEach { row, poi in
                assertThat(sut, hasViewConfiguredFor: poi, section: section, row: row, file: file, line: line)
            }
        }
    }
    
    private func assertThat(_ sut: POIsViewController, hasViewConfiguredFor poi: POI, section: Int, row: Int, file: StaticString = #filePath, line: UInt = #line) {
        let view = sut.poiCell(section: section, row: row)
        
        guard let cell = view as? POICell else {
            return XCTFail("Expected \(POICell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
        }
        
        XCTAssertEqual(cell.nameText, poi.name, "Expected name text to be \(String(describing: poi.name)) for poi view at section (\(section)), row: \(row)", file: file, line: line)
        
        XCTAssertEqual(cell.addressText, poi.address, "Expected address text to be \(String(describing: poi.address)) for poi view at section (\(section)), row: \(row)", file: file, line: line)
        
        XCTAssertEqual(cell.descriptionText, poi.description, "Expected description text to be \(String(describing: poi.description)) for poi view at section (\(section)), row: \(row)", file: file, line: line)
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
    
    func completeWithSuccess(_ pois: [POI], at index: Int = 0) {
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
    
    func poiCell(section: Int, row: Int) -> UICollectionViewCell? {
        let dataSource = collectionView.dataSource
        let indexPath = IndexPath(row: row, section: section)
        return dataSource?.collectionView(collectionView, cellForItemAt: indexPath)
    }
    
    var numberOfRenderedPOIs: Int {
        var retValue = 0
        for section in 0..<collectionView.numberOfSections {
            retValue += collectionView.numberOfItems(inSection: section)
        }
        return retValue
    }
}

private extension POICell {
    var nameText: String? {
        return titleLabel.text
    }
    
    var descriptionText: String? {
        return descLabel.text
    }
    
    var addressText: String? {
        return addressLabel.text
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
